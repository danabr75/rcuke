require_relative 'spec_helper.rb'
# Rspec tests for both ruby and bash versions of rcuke.

describe "ruby rcuke retries" do
  before(:each) do
    sleep WAIT_BEFORE_TESTS if WAIT_BEFORE_TESTS
    @default_options = {
      :server_location => "http://" + SERVER_ADDRESS + ':' + SERVER_PORT,
      :running_internal_tests => true
    }
  end

  after(:each) do
  end

  describe "Should not retry when failures encountered if no reruns enables" do
    it "should halt an error message if no features passed regardless of options" do
      options = {
        :enable_reruns => false
      }

      features_path = EXAMPLE_SERVER_LOCATION + '/features/some_failing.feature'

      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options.merge(options))
      end

      output = output.gsub(/\n/, '')
      output.should_not include('Encountered failures. Retrying')
      output.should include('SCENARIOS PASSED: 2')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  4')

      # Results will be from final run
      success_count.should == 2
      # failure_count.should == 2
      total_count.should == 4
      rerun_count.should == 0 # 0 is the first run
    end
  end

  describe "Should continue to retry when failures encountered" do
    it "and should halt with an error message if no features passed regardless of options" do
      options = {
        :enable_reruns => true,
        :max_rerun_count => 2
      }

      features_path = EXAMPLE_SERVER_LOCATION + '/features/some_failing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options.merge(options))
      end

      output = output.gsub(/\n/, '')
      output.should include('Encountered failures. Retrying')
      output.should include('SCENARIOS PASSED: 2')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  4')

      # Results will be from final run
      success_count.should == 2
      # failure_count.should == 2
      total_count.should == 4
      rerun_count.should == 2 # 0 is the first run
    end
  end

  describe "Should retry once if no amount specified" do
    it "should halt an error message if no features passed regardless of options" do
      options = {
        :enable_reruns => true
      }

      features_path = EXAMPLE_SERVER_LOCATION + '/features/some_failing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options.merge(options))
      end

      output = output.gsub(/\n/, '')
      output.should include('Encountered failures. Retrying')
      output.should include('SCENARIOS PASSED: 2')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  4')

      # Results will be from final run
      success_count.should == 2
      # failure_count.should == 2
      total_count.should == 4
      rerun_count.should == 1
    end
  end

  # Intermittently Fails
  describe "Should not retry if no failures" do
    it "should halt an error message if no features passed regardless of options" do
      options = {
        :enable_reruns => true,
        :max_rerun_count => 2
      }

      features_path = EXAMPLE_SERVER_LOCATION + '/features/passing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], @default_options.merge(options))
      end

      output = output.gsub(/\n/, '')
      output.should_not include('Encountered failures. Retrying')
      output.should include('SCENARIOS PASSED: 2')
      # output.should include('SCENARIOS FAILED: 0')
      output.should include('SCENARIOS TOTAL:  2')

      # Results will be from final run
      success_count.should == 2
      # failure_count.should == 0
      total_count.should == 2
      rerun_count.should == 0
    end
  end
end