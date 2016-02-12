require_relative 'spec_helper.rb'
# Rspec tests for both ruby and bash versions of rcuke.

describe "ruby rcuke tags" do
  before(:each) do
    sleep WAIT_BEFORE_TESTS if WAIT_BEFORE_TESTS
    @default_options = {
      :server_location => "http://" + SERVER_ADDRESS + ':' + SERVER_PORT,
      :running_internal_tests => true
    }
  end

  after(:each) do
  end

  describe "with the features tagged" do
    it "should run with passing features" do
      options = {
      }
      
      features_path = EXAMPLE_SERVER_LOCATION + '/features/some_failing.feature'
      cucumber_options = [
        features_path,
        '--tags',
        '@passing'
      ]

      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start(cucumber_options, @default_options.merge(options))
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 2')
      # output.should include('SCENARIOS FAILED: 0')
      output.should include('SCENARIOS TOTAL:  2')

      # Results will be from final run
      success_count.should == 2
      # failure_count.should == 0
      total_count.should == 2
      rerun_count.should == 0 # 0 is the first run
    end

    it "should run with failing features" do
      options = {
      }

      features_path = EXAMPLE_SERVER_LOCATION + '/features/some_failing.feature'
      cucumber_options = [
        features_path,
        '--tags',
        '@failing'
      ]

      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start(cucumber_options, @default_options.merge(options))
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 0')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  2')

      # Results will be from final run
      success_count.should == 0
      # failure_count.should == 2
      total_count.should == 2
      rerun_count.should == 0 # 0 is the first run
    end
  end

  describe "without the features tagged" do
    it "should run with passing features" do
      options = {
      }

      features_path = EXAMPLE_SERVER_LOCATION + '/features/some_failing.feature'
      cucumber_options = [
        features_path,
        '--tags',
        '~@passing'
      ]

      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start(cucumber_options, @default_options.merge(options))
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 0')
      # output.should include('SCENARIOS FAILED: 2')
      output.should include('SCENARIOS TOTAL:  2')

      # Results will be from final run
      success_count.should == 0
      # failure_count.should == 2
      total_count.should == 2
      rerun_count.should == 0 # 0 is the first run
    end

    it "should run with failing features" do
      options = {
      }

      features_path = EXAMPLE_SERVER_LOCATION + '/features/some_failing.feature'
      cucumber_options = [
        features_path,
        '--tags',
        '~@failing'
      ]

      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start(cucumber_options, @default_options.merge(options))
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 2')
      # output.should include('SCENARIOS FAILED: 0')
      output.should include('SCENARIOS TOTAL:  2')

      # Results will be from final run
      success_count.should == 2
      # failure_count.should == 0
      total_count.should == 2
      rerun_count.should == 0 # 0 is the first run
    end
  end

  describe "with multiple tags" do
    it "should run with failing features" do
      options = {
      }

      features_path = EXAMPLE_SERVER_LOCATION + '/features/some_failing.feature'
      cucumber_options = [
        features_path,
        '--tags',
        '~@failing, @passing'
      ]

      failure_count, success_count, total_count, rerun_count = [nil, nil, nil, nil]
      
      output = capture_stdout do
        failure_count, success_count, total_count, rerun_count = Rcuke::CucumberWrapper.start(cucumber_options, @default_options.merge(options))
      end

      # output = output.gsub(/\n/, '')
      output.should include('SCENARIOS PASSED: 2')
      # output.should include('SCENARIOS FAILED: 0')
      output.should include('SCENARIOS TOTAL:  2')

      # Results will be from final run
      success_count.should == 2
      # failure_count.should == 0
      total_count.should == 2
      rerun_count.should == 0 # 0 is the first run
    end
  end
end