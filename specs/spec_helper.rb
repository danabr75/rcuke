require 'thin'
require 'stringio'
require 'rspec'
require 'rails'
require 'tempfile'
require 'tmpdir'

# Server is getting spammed too fast
WAIT_BEFORE_TESTS = 2

CURRENT_PATH = File.dirname(__FILE__)
# CURRENT_PATH = "/home/danabr/projects/rcuke/specs/"
# # require 'mail
require CURRENT_PATH + '/../lib/rcuke.rb'
# Put rcuke script into ruby's load path
$:.unshift(CURRENT_PATH + '/../bin/')
# puts %x[PATH=$PATH:#{File.dirname(__FILE__) + '/../bin/'}]

# example_server_config = EXAMPLE_SERVER_LOCATION + '//config.ru'
EXAMPLE_SERVER_LOCATION = CURRENT_PATH + '/TestApp'
SERVER_ADDRESS = '127.0.0.1'
SERVER_PORT = '7001'

@temp_log_file = Tempfile.new(['server_log', '.log'])
@temp_pid_file = Tempfile.new(['server_pid', '.pid'])
@temp_config_file = Tempfile.new(['server_config', '.yml'])

$TEMP_DIR = Dir.mktmpdir
# Start Server
@config_settings = %Q{---
pid: #{@temp_pid_file.path}
log: #{@temp_log_file.path}
rackup: #{EXAMPLE_SERVER_LOCATION}/config.ru
max_conns: 1024
timeout: 30
port: #{SERVER_PORT}
chdir: #{EXAMPLE_SERVER_LOCATION}
max_persistent_conns: 512
environment: development
servers: 1
address: #{SERVER_ADDRESS}
daemonize: true
require: []}
# puts "THIN SETTINGS: #{@config_settings}"
@temp_config_file.write(@config_settings)
@temp_config_file.rewind
%x[thin -C #{@temp_config_file.path} start]
puts "IF exiting prematurely, please run 'thin -C #{@temp_config_file.path} stop' to kill the local test server or run `ps aux | grep thin' and kill 'thin server (127.0.0.1:7001)'"

at_exit do
  # Stop Server
  puts "Killing local test server"
  %x[thin -C #{@temp_config_file.path} stop]
  @temp_log_file.close!
  @temp_pid_file.close!
  @temp_config_file.close!

  FileUtils.remove_entry_secure $TEMP_DIR
  $TEMP_DIR = nil # Would still have path, but no corresponding directory
end



RSpec.configure do |config|
  # original_stderr = $stderr
  # original_stdout = $stdout
  original_app_host = $REMOTE_APP_HOST
  original_run_on_remote = $RUN_CUKES_ON_REMOTE_SERVER 

  config.before(:all) do
    # Global temporary directory, allows us to store cuke screenshots cleanly

  end

  config.after(:all) do
  end

  config.before(:each) do
  end

  config.after(:each) do
    $REMOTE_APP_HOST = original_app_host
    $RUN_CUKES_ON_REMOTE_SERVER = original_run_on_remote
  end
end

# Move to helper file later
def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end

def capture_stderr(&blk)
  old = $stderr
  $stderr = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stderr = old
end