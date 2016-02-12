require_relative 'spec_helper.rb'

describe "bash rcuke tests" do
  before(:each) do
    sleep WAIT_BEFORE_TESTS if WAIT_BEFORE_TESTS
    @bash_env = "PATH=$PATH:#{File.dirname(__FILE__) + '/../bin/'}; export TEMP_DIR=#{$TEMP_DIR};"
    @default_options = {
      :server_location => "http://" + SERVER_ADDRESS + ':' + SERVER_PORT,
      :running_internal_tests => true
    }
  end

  after(:each) do
  end

  describe "Missing features path" do
    it "should halt an error message if no features passed" do
      output = %x[#{@bash_env} rcuke]

      # output = output.gsub(/\n/, '')
      output.should =~ /^Error: No features location given to run cuke tests on.(.*)/
    end

    it "should halt an error message if no features passed with options" do
      output = %x[#{@bash_env} rcuke -NRT]

      # output = output.gsub(/\n/, '')
      output.should =~ /^Error: No features location given to run cuke tests on.(.*)/
    end
  end

  describe "Empty features" do
    it "should run with 0 scenarios" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/empty.feature'
      # No need to pass in server, not even checked for empty features
      output = %x[#{@bash_env} rcuke #{features_path} -T]

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS TOTAL:  0')
    end

    it "should run with 0 scenarios with options" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/empty.feature'
      output = %x[#{@bash_env} rcuke #{features_path} -s #{@default_options[:server_location]} -T]

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS TOTAL:  0')
    end
  end

  describe "All Features" do
    it "should correctly report the passing and failing cukes" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]

      output = %x[#{@bash_env} bin/rcuke #{features_path} -S #{@default_options[:server_location]} -T]

      # # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 4')
      # output.should include('SCENARIOS FAILED: 4')
      output.should include('SCENARIOS TOTAL:  8')
    end
  end


  describe "All Features with options" do
    it "should correctly report the passing and failing cukes" do
      features_path = EXAMPLE_SERVER_LOCATION + '/features/'
      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      options = {

      }

      output = %x[#{@bash_env} rcuke #{features_path} -s #{@default_options[:server_location]} -T]

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 4')
      # output.should include('SCENARIOS FAILED: 4')
      output.should include('SCENARIOS TOTAL:  8')
    end
  end
end