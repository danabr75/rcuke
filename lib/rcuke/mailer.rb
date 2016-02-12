require 'mail'

# Mails out results of cucumber tests with optional pdf file of raw results.
class Mailer
  # Setup Mail defaults with either custom smtp settings to send mail by itself or use local server smtp server, sendmail.
  def self.setup_defaults(smtp, verbose, internal_test)
    Mail.defaults do
      # If running internal rspec or cucumber tests, do not send emails
      if internal_test
        delivery_method :test
      elsif smtp.nil? || smtp.empty?
        puts "SMTP options not defined. Attempting to use sendmail." if verbose
        delivery_method :sendmail
      else
        puts "SMTP options defined. Attempting to use custom SMTP settings." if verbose
        delivery_method :smtp, smtp
      end
    end
  end

  # Submit success email if no failure scenarios
  def self.submit_success_email(file, success_count, total_count, emails, time_ran, opts = {})
    setup_defaults(opts[:smtp_settings], opts[:verbose], opts[:running_internal_tests])
    email_subject = opts[:custom_title] || "Cucumber test for #{$REMOTE_APP_HOST}"
    status = total_count > 0 ? "ALL #{total_count} PASSED" : "NO TESTS RAN"
    mail = Mail.new do
      # from is necessary for mailer, but may be overridden by SMTP server
      from     !opts[:smtp_settings].nil? ? opts[:smtp_settings][:user_name] : 'no-reply@fillerdomain.com'
      to       emails
      subject  "#{email_subject} - #{status}#{(': RETRY ' + opts[:rerun_count].to_s) if opts[:rerun_count] > 0}"
      html_part do
        content_type 'text/html; charset=UTF-8'
        body "<div>
              Ran at time: #{time_ran}.<br>
              #{'<b>Test Ran locally (Not against a running server).</b><br>' if opts[:remote_server] == false}
              Scenarios passed: #{success_count}.<br>
              Out of total Scenarios: #{total_count}.<br>
              NOTE: Scenarios count differences may be due to some being marked pending or undefined.<br>
              #{'Warning: ' + opts[:file_format].to_s + ' file of results could not be generated<br>' if file.nil?}
              </div>"
      end
      # CUKE BUG: output file appears to be empty if no scenarios failed?
      # add_file "#{file.path}" if file
    end
    mail.deliver
  end

  # Submit failure email if one of more snenario failures exist
  def self.submit_failure_email(file, success_count, failure_count, total_count, failures_list, emails, time_ran, opts = {})
    setup_defaults(opts[:smtp_settings], opts[:verbose], opts[:running_internal_tests])
    email_subject = opts[:custom_title] || "Cucumber test for #{$REMOTE_APP_HOST}"
    mail = Mail.new do
      # from is necessary for mailer, but may be overridden by SMTP server
      from     !opts[:smtp_settings].nil? ? opts[:smtp_settings][:user_name] : 'no-reply@fillerdomain.com'
      to       emails
      subject  "#{email_subject} - #{failure_count} FAILED & #{success_count} PASSED#{(': RETRY ' + opts[:rerun_count].to_s) if opts[:rerun_count] > 0}"
      html_part do
        content_type 'text/html; charset=UTF-8'
        body "<div>
              Ran at time: #{time_ran}.<br>
              #{'<b>Test ran locally (Not against a running server).</b><br>' if opts[:remote_server] == false}
              Scenarios passed: #{success_count}.<br>
              Scenarios failed: #{failure_count}.<br>
              Out of total Scenarios: #{total_count}.<br>
              NOTE: Scenarios count differences may be due to some being marked pending or undefined.<br>
              <br>
              Scenarios Failed:<br>
              #{failures_list}
              #{'Warning: ' + opts[:file_format].to_s + ' file of results could not be generated<br>' if file.nil?}
              </div>
              <br>"
      end
      add_file "#{file.path}" if file
    end
    mail.deliver
  end
end