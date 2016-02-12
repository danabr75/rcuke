module Rcuke
  # Required String
  GEM_NAME = "rcuke"
  # Required String
  VERSION = '1.2.8'
  # Optional String or Array of Strings
  AUTHORS = ["Ben Dana"]
  # Optional String or Array of Strings
  EMAILS = ["b.dana@prometheuscomputing.com"]
  # Optional String
  HOMEPAGE = nil
  # Required String
  SUMMARY = %q{Remote Cucumber Launcher with optional email notification}
  # Optional String
  DESCRIPTION = SUMMARY
  
  # Required Symbol
  # This specifies the language the project is written in (not including the version, which is in LANGUAGE_VERSION).
  # A project should only have one LANGUAGE (not including, for example DSLs such as templating languages).
  # If a project has more than one language (not including DSLs), it should be split.
  # The reason is that mixing up languages in one project complicates packaging, deployment, metrics, directory structure, and many other aspects of development.
  # Choices are currently:
  #   * :ruby - project contains ZERO java code
  #           it may contain JRuby code and depend or jars or :java projects,  if RUNTIME_VERSIONS has a :jruby key
  #           implies packaging as gem
  #   * :java - contains ZERO ruby code (with exception of meta_info.rb), and depends on zero Ruby code.
  #           implies packaging as jar - may eventually also support ear, war, sar, etc
  LANGUAGE = :ruby
  # This differs from Runtime version - this specifies the version of the syntax of LANGUAGE
  LANGUAGE_VERSION = ['> 1.8.1', '< 1.9.3']
  RUNTIME_VERSIONS = {
    :mri => ['> 1.8.1']
  }
  TYPE = :utility
  LAUNCHER = nil
  DEPENDENCIES_RUBY = {
    'mail' => '', # -v 2.5.4
    'pdfkit' => '', # -v 0.6.2
    'slave' => '', # -v 1.3.2

    # Dev dependencies
    'poltergeist' => '', # -v 1.5.0
    'phantomjs' => '', # -v 1.9.7 # 1.9.8.0
    'thin' => '', # -v 1.6.2
    'rspec' => '< 2.98.0', #  2.14.1
    'cucumber' => '~> 1.3', # 1.3.7
    'thin' => '~> 1.6', # 1.6.3, 1.6.2
    'capybara' => '', #(2.4.3)
    'capybara-screenshot' => '~> 0.3', #(0.3.14)
    'capybara-webkit' => '', #(1.1.0)
    'wkhtmltopdf-binary' => '', # (0.9.9.3)

    # 'rails' => '~> 4.3',
    # 'jquery-rails' => '',
    # 'sqlite3' => ''
  }
  DEVELOPMENT_DEPENDENCIES_RUBY = {
    # gem install rails -v "~> 4.2" && gem install jquery-rails sqlite3 cucumber-rails
    'rails' => '~> 4.2',
    'jquery-rails' => '',
    'sqlite3' => '',
    'cucumber-rails' => ''
  } 
  DEPENDENCIES_MRI = { }
  DEPENDENCIES_JRUBY = { }
  DEVELOPMENT_DEPENDENCIES_MRI = { }
  DEVELOPMENT_DEPENDENCIES_JRUBY = { }
  
  # Java dependencies are harder to handle because Java does not have an equivalent of Ruby gem servers.
  # The closest thing is Maven repositories, which are growing in popularity, but not yet ubiquitous enough to warrant supporting in this tool.
  # Currently only the keys are used, version info is ignored.
  # Keys can be the names of Jars (complete, including any version info embedded in name) that must be located in JARCHIVE (key must end in .jar), or the name of a constant (key must not end in .jar).
  # Constsants must be defined in this module. Constants must not be computed from absolute paths (use environmental variables if necessary).
  # Support for constants is provided primarily to accomodate MagicDraw, which requires a large number of jars.
  DEPENDENCIES_JAVA = { }
  DEPENDENCIES_JAVA_SE = { }
  DEPENDENCIES_JAVA_ME = { }
  DEPENDENCIES_JAVA_EE = { }
  
  # An Array of strings that YARD will interpret as regular expressions of files to be excluded.
  YARD_EXCLUDE = []

  # Set global for app host for env.rb file to find
  $REMOTE_APP_HOST = 'http://localhost:7000'
  # Set optional global boolean to for cucumber environment to switch on
  $RUN_CUKES_ON_REMOTE_SERVER  = true
  # Set default retries to 1
  DEFAULT_MAX_RETRIES_ON_FAILURE = 1
end




