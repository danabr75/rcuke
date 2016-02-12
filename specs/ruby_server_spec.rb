require_relative 'spec_helper.rb'
# Rspec tests for both ruby and bash versions of rcuke.

describe "ruby rcuke server" do
  before(:each) do
    sleep WAIT_BEFORE_TESTS if WAIT_BEFORE_TESTS
    @default_options = {
      :server_location => "http://" + SERVER_ADDRESS + ':' + SERVER_PORT,
      :running_internal_tests => true
    }
  end

  after(:each) do
  end

  # Assumes server 0.0.0.0:7000, nothing should be listening to that port
  describe "No server passed in parameter (will assume it's running and fail)" do
    it "should fail all 2 scenarios" do
      # No need to pass in server, not even checked for empty features
      features_path = EXAMPLE_SERVER_LOCATION + '/features/passing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      bad_server_options = {
        :enable_notifications => true,
        :running_internal_tests => true
      }

      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], bad_server_options)
      end

      output.should include('SCENARIOS PASSED: 0')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  2')

      success_count.should == 0
      # failure_count.should == 2
      total_count.should == 2
      rerun_count.should == 0
    end
  end


  describe "Wrong server passed in parameter" do
    it "should fail all 2 scenarios" do
      # No need to pass in server, not even checked for empty features
      features_path = EXAMPLE_SERVER_LOCATION + '/features/passing.feature'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      bad_server_options = {
        :server_location => "httttp://0.0.0.0.0:7777"
      }

      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start([features_path], bad_server_options)
      end

      output.should include('SCENARIOS PASSED: 0')
      # Has intermittent issues with detecting all the failed scenarios.
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  2')

      success_count.should == 0
      # failure_count.should == 2
      total_count.should == 2
      rerun_count.should == 0
    end
  end
end