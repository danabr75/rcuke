require 'fileutils'
require 'cucumber'
require 'tempfile'
require 'slave'
require_relative 'meta_info'
require_relative 'mailer'
require_relative 'kernel_without_exit'
require_relative 'pdf_generator'

# Redefine exit to call exit! so that we don't run into issues with at_exit callbacks from child.
class Slave
  def exit(*args)
    exit!(*args)
  end
end

module Rcuke
  # Class uses wraps cucumber internals to start a cucumber test( or series of tests).
  class CucumberWrapper
    # Create and set all global components and then start (and possibly iterate over) the cuke tests
    def self.start(cucumber_args = [], opts = {})
      # Handle missing scenarios
      if cucumber_args.nil? || cucumber_args.empty?
        puts "Error: No features location given to run cuke tests on."
        return [nil, nil, nil, nil]
      end

      # Not a case that we officially handle, but could potentially solve a lot of headaches
      if cucumber_args.is_a?(String)
        puts "Warning: Scenario passed in was a string, not an array. Converting to array..."
        cucumber_args = [cucumber_args]
      end

      # Set defaults
      $REMOTE_APP_HOST = opts[:server_location] if opts[:server_location]
      opts[:max_rerun_count] ||= DEFAULT_MAX_RETRIES_ON_FAILURE
      opts[:rerun_count] ||= 0
      $RUN_CUKES_ON_REMOTE_SERVER = opts[:remote_server] if !opts[:remote_server].nil?
      opts[:embed_screenshots] = true if opts[:embed_screenshots].nil?
      $REMOTE_APP_HOST = nil if opts[:remote_server] == false
      opts[:file_format] = 'pdf' if opts[:file_format].nil?

      failure_count, success_count, total_count, output = [nil, nil, nil, nil]
      # Tests have to be run as slaves in order to get seperate environments from each other.
      # Cucumber was not designed to be rerun in the same environment.
      time_ran = Time.now
      puts "Running Cucumber tests at #{time_ran}. This may take a while..."
      failure_count, success_count, total_count, output = Slave.object { run_tests(cucumber_args.dup, time_ran, opts.dup) }

      while opts[:enable_reruns] && failure_count > 0 && opts[:max_rerun_count] >= 0 && opts[:rerun_count] < opts[:max_rerun_count]
        # Only print out output of each try if verbose
        puts output if opts[:verbose]
        puts "Encountered failures. Retrying #{opts[:rerun_count]} out of a possible #{opts[:max_rerun_count]} times..."
        puts
        puts "*" * 80
        puts
        opts[:rerun_count] = opts[:rerun_count] + 1
        time_ran = Time.now
        puts "Running Cucumber tests at #{time_ran}. This may take a while..."
        failure_count, success_count, total_count, output = Slave.object { run_tests(cucumber_args.dup, time_ran, opts.dup) }
        puts "Ending last retry." if opts[:rerun_count] == opts[:max_rerun_count]
      end

      # Print output of last test run
      puts output
      puts 'Finished.'
      return [failure_count, success_count, total_count, opts[:rerun_count]]
    end


    # Run the cucumber tests
    def self.run_tests(cucumber_args = [], time_ran = Time.now, opts = {})
      output = ''
      on_disk = nil
      # If new file creation is to fail, best to fail early before time-taking tests are run
      if opts[:store_file_on_disk]
        path = opts[:store_file_on_disk]
        path = path + "-#{opts[:rerun_count]}" if opts[:enable_reruns] && opts[:rerun_count] > 0
        on_disk = File.new(opts[:store_file_on_disk], 'w') if opts[:store_file_on_disk]
      end

      # if opts[:store_html_on_disk]
      #   path = opts[:store_html_on_disk]
      #   path = path + "-#{opts[:rerun_count]}" if opts[:enable_reruns] && opts[:rerun_count] > 0
      #   on_disk_html = File.new(opts[:store_html_on_disk], 'w') if opts[:store_html_on_disk]
      # end

      # Push format options into Cucumber array parameter
      if opts[:enable_notifications] || opts[:store_file_on_disk]
        output_file = Tempfile.new(['output', '.html'])
        # Push format stylings into array if notifications enabled,
        cucumber_args.push('--format')
        cucumber_args.push('html')
        cucumber_args.push('--out')
        cucumber_args.push(output_file.path)
      end

      runtime = Cucumber::Runtime.new
      runtime.load_programming_language('rb')

      std_out = opts[:verbose] ? STDOUT : StringIO.new
      std_err = opts[:verbose] ? STDERR : StringIO.new
      cuke = Cucumber::Cli::Main.new(cucumber_args, nil, std_out, std_err, KernelWithoutExit)

      cuke.execute!(runtime)
      failure_count = runtime.scenarios(:failed).count
      success_count = runtime.scenarios(:passed).count
      total_count = runtime.scenarios.count


      output << "\n"
      output << "SCENARIOS PASSED: #{success_count}\n"
      output << "SCENARIOS FAILED: #{failure_count}\n"
      output << "SCENARIOS TOTAL:  #{total_count}\n"
      output << "\n"

      failures_list = "" if opts[:enable_notifications] && runtime.scenarios(:failed).any?
      output << "FAILED SCENARIOS:\n" if runtime.scenarios(:failed).any?
      runtime.scenarios(:failed).each do |failure|
        output << "  " + failure.location.to_s + "\n"
        failures_list << "#{failure.location}<br>" if opts[:enable_notifications]
      end

      # create PDF of results if notifications enabled if saving to hard drive
      pdf_file = nil
      if opts[:enable_notifications] || opts[:store_file_on_disk]
        edited_output_file = Tempfile.new(['edited_output', '.html'])
        output_file.each_line do |line|
          # Show Screenshots in HTML Doc
          image_css = "style=\"border: 1px; border-style: solid; width: 600px; display: block; margin-left: auto; margin-right: auto;\""
          edited_line = line.gsub(/<img([^>]*)style="display: none"/, "<img#{$1} align=\"middle\" #{image_css}") if opts[:embed_screenshots]
          # Insert CSS in HTML Doc
          edited_line = edited_line.sub(/^body {$/, "pre {white-space: pre-wrap;}\nbody {\nmax-width: 700px;\nword-wrap: break-word;\n")
          edited_output_file.write(edited_line)
        end
        edited_output_file.rewind

        email_file = nil
        if opts[:file_format] == 'pdf'
          output << "Creating PDF of cucumber results... (hint: if pdf is empty and all cukes are failing, check to make sure server location is correctly spelled.)\n"
          pdf_generator = PdfGenerator.new
          pdf_file = pdf_generator.create_pdf(edited_output_file)
          email_file = pdf_file
        else
          email_file = edited_output_file
        end

        # Save PDF physically
        if opts[:store_file_on_disk] && opts[:file_format] == 'pdf'
          output << "Saving PDF to '#{opts[:store_file_on_disk]}'...\n"
          pdf_file.rewind # just in case
          pdf_file.each_line do |line|
            on_disk.write(line)
          end
          pdf_file.rewind
          on_disk.close
        end

        # Save HTML physically
        if opts[:store_file_on_disk] && opts[:file_format] == 'html'
          output << "Saving HTML to '#{opts[:store_file_on_disk]}'...\n"
          edited_output_file.rewind # just in case
          edited_output_file.each_line do |line|
            on_disk.write(line)
          end
          edited_output_file.rewind
          on_disk.close
        end
      end

      # Email results, and possibly file
      if opts[:enable_notifications]
        emails = opts[:notification_emails] && opts[:notification_emails].any? ? opts[:notification_emails] : []
        email = (%x[git config --get user.email]).sub(/\n$/, '')
        output << "WARNING: No email received.\n" if emails.empty?
        output << "Attempting to use email from git config: '#{email}'\n" if email
        emails << email if emails.empty? && email

        output << "Sending out email(s) to: #{emails.join(', ')}\n" if emails.any?
        if failure_count > 0 && emails.any?
          Mailer.submit_failure_email(email_file, success_count, failure_count, total_count, failures_list, emails, time_ran, opts)
        elsif emails.any?
          Mailer.submit_success_email(email_file, success_count, total_count, emails, time_ran, opts)
        end
        output << "Finished sending emails.\n" if emails.any?
        output << "Unable to send any emails, none found or specified\n" if emails.empty?
        output << "Performing cleanup...\n"
        pdf_generator.close_pdf if opts[:file_format] == 'pdf'
        output_file.close!
        edited_output_file.close!
      end

      output << "Finished running tests.\n"
      return [failure_count, success_count, total_count, output]
    end
  end
end