require 'capybara/cucumber'
require 'capybara-screenshot'
require 'capybara-screenshot/cucumber'
require 'capybara'
require 'capybara/webkit'
require 'phantomjs'
require 'capybara/poltergeist'

# Setup for remote server
# First for ruby globals for ruby tests, the second is for bash globals for bash tests
if $RUN_CUKES_ON_REMOTE_SERVER || ENV['RUN_CUKES_ON_REMOTE_SERVER']
  puts "RUNNING CUKES ON REMOTE SERVER"
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
  end
  Capybara.default_driver = :poltergeist
  Capybara.run_server = false
  Capybara.app_host = $REMOTE_APP_HOST || ENV['REMOTE_APP_HOST']
else
  puts "NOT RUNNING CUKES ON REMOTE SERVER"
  Capybara.default_driver = :webkit
end

# Setup Capybara to run

# Using temp folder to avoid clutter
# First for ruby globals for ruby tests, the second is for bash globals for bash tests
if $TEMP_DIR || ENV['TEMP_DIR']
  Capybara.save_and_open_page_path = "#{$TEMP_DIR || ENV['TEMP_DIR']}/capybara"
else
  Capybara.save_and_open_page_path = "./tmp/capybara"
end


# Time to wait for javascript to run on pages.
Capybara.default_max_wait_time = 3

app, options = Rack::Builder.parse_file(File.dirname(__FILE__) + '/../../config.ru')

Capybara.app = app