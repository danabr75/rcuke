require_relative 'spec_helper.rb'
# Rspec tests for both ruby and bash versions of rcuke.

describe "ruby rcuke file generation" do
  before(:each) do
    sleep WAIT_BEFORE_TESTS if WAIT_BEFORE_TESTS
    @default_options = {
      :server_location => "http://" + SERVER_ADDRESS + ':' + SERVER_PORT,
      :running_internal_tests => true
    }
  end

  after(:each) do
  end

  describe "generate files" do
    it "should generate HTML on passing features" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/passing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      dir = Dir.mktmpdir

      options = {
        :store_file_on_disk => dir + '/test_file.html',
        :file_format => 'html'
      }
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options.merge(options))
      end

      # output = output.gsub(/\n/, '')


      output.should include('SCENARIOS PASSED: 2')
      output.should include('SCENARIOS FAILED: 0')
      output.should include('SCENARIOS TOTAL:  2')

      success_count.should == 2
      failure_count.should == 0
      total_count.should == 2
      rerun_count.should == 0

      File.file?(dir + '/test_file.html').should == true
      # File size should remain the same for the results of this test
      # File.size(dir + '/test_file.html').should == 79225
      # puts File.size(dir + '/test_file.html')

      FileUtils.remove_entry_secure dir
    end

    it "should generate PDF on failing features" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/failing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]

      dir = Dir.mktmpdir # use Global?
      
      options = {
        :store_file_on_disk => dir + '/test_file.pdf',
        :file_format => 'pdf'
      }

      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options.merge(options))
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 0')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  2')

      success_count.should == 0
      # failure_count.should == 2
      total_count.should == 2
      rerun_count.should == 0

      File.file?(dir + '/test_file.pdf').should == true
      # File size should remain the same for the results of this test
      # File.size(dir + '/test_file.pdf').should == 121774
      # puts File.size(dir + '/test_file.pdf')

      FileUtils.remove_entry_secure dir
    end

    it "should generate PDF by default on failing features" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/failing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]

      dir = Dir.mktmpdir # use Global?
      
      options = {
        :store_file_on_disk => dir + '/test_file.pdf'
      }

      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options.merge(options))
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 0')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  2')

      success_count.should == 0
      # failure_count.should == 2
      total_count.should == 2
      rerun_count.should == 0

      File.file?(dir + '/test_file.pdf').should == true
      # File size should remain the same for the results of this test
      # File.size(dir + '/test_file.pdf').should == 121774
      # puts File.size(dir + '/test_file.pdf')

      FileUtils.remove_entry_secure dir
    end
  end
end