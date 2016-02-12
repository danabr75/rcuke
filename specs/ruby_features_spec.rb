require_relative 'spec_helper.rb'
# Rspec tests for both ruby and bash versions of rcuke.

describe "ruby rcuke various features" do
  before(:each) do
    sleep WAIT_BEFORE_TESTS if WAIT_BEFORE_TESTS
    @default_options = {
      :server_location => "http://" + SERVER_ADDRESS + ':' + SERVER_PORT,
      :running_internal_tests => true
    }
  end

  after(:each) do
  end
  
  describe "Missing or Empty Features" do
    it "should halt an error message if no features passed" do
      output = capture_stdout do
        Rcuke::CucumberWrapper.start
      end

      output = output.gsub(/\n$/, '')
      output.should == 'Error: No features location given to run cuke tests on.'
    end

    it "should halt an error message if no features passed regardless of options" do
      options = {
        :enable_reruns => true,
        :enable_notifications => true
      }

      return_value = nil

      output = capture_stdout do
        return_value = Rcuke::CucumberWrapper.start([], @default_options.merge(options))
      end

      output = output.gsub(/\n/, '')
      output.should == 'Error: No features location given to run cuke tests on.'

      return_value.should == [nil, nil, nil, nil]
    end
  end  

  describe "Empty Features" do
    it "should run 0 scenarios" do
      # No need to pass in server, not even checked for empty features
      features_path = EXAMPLE_SERVER_LOCATION + '/features/empty.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]

      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path])
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 0')
      output.should include('SCENARIOS FAILED: 0')
      output.should include('SCENARIOS TOTAL:  0')

      success_count.should == 0
      failure_count.should == 0
      total_count.should == 0
      rerun_count.should == 0
    end
  end

  describe "Passing Features" do
    it "should pass without failures" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/passing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options)
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 2')
      output.should include('SCENARIOS FAILED: 0')
      output.should include('SCENARIOS TOTAL:  2')

      success_count.should == 2
      failure_count.should == 0
      total_count.should == 2
      rerun_count.should == 0
    end
  end

  describe "Failing Features" do
    it "should pass with failures" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/failing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options)
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 0')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  2')

      success_count.should == 0
      # failure_count.should == 2
      total_count.should == 2
      rerun_count.should == 0
    end
  end
  describe "All Features" do
    it "should correctly report the passing and failing cukes" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options)
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 4')
      # output.should include('SCENARIOS FAILED: 4')
      output.should include('SCENARIOS TOTAL:  8')

      success_count.should == 4
      # failure_count.should == 4
      total_count.should == 8
      rerun_count.should == 0
    end
  end
end