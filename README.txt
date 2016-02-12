rcuke
    by b.dana

== DESCRIPTION:

Remote Cucumber tests with email notifications
Must run under ruby-1.9.3 (rdiscount 2.1.6 is not supported on earlier rubies)
Run via: "rcuke"

== FEATURES/PROBLEMS:

* FIXME (list of features or problems)

== SYNOPSIS:
  * Run like you would most cucumber tests

  rcuke features/

  * New options are added in.
  * -S allows to test on live servers (see requirements for cucumber env.rb setup).
  * -N for email notifications to be sent out on completion.

  rcuke /path/to_features/feature_one.feature /path/to_features/feature_one.feature -S http://www.examplesite.com

  rcuke features/feature_one.feature -N test@domain.com -S http://www.examplesite.com

  * Can be used in rake schedules or cron jobs to automatically run.
  * First argument is an array of the cucumber parameters. Second is a hash of the rcuke options. See bin/rcuke for exact option names.
  rcuke_args = {:enable_notifications => true, :notification_emails => [email1, email2], :server_location => 'http://www.somehwere.com'}
  cuke_args = ['--tags', '@passing']
  Rcuke::CucumberWrapper.start(cuke_args, rcuke_args)

== REQUIREMENTS:

  *Requires that you do not use capybara webkit on the server project you are running on, if running remotely.
  *Recommend you have your server's env.rb file set up as like the following:

  require 'phantomjs'
  require 'capybara/poltergeist'

  if $RUN_CUKES_ON_REMOTE_SERVER
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
    end
    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist
    Capybara.run_server = false
    Capybara.app_host = $REMOTE_APP_HOST
    Capybara.default_host = $REMOTE_APP_HOST
  else
    # Else use webkit or whatever your default is when running cukes locally
    Capybara.default_driver = :webkit
  end

  *IMPORTANT rcuke sets the server variable unless you already have it set in your env.rb file, then ignore: $REMOTE_APP_HOST

== INSTALL:

* Requires the following to be installed
  gem - mail (2.5.4)
  gem - pdfkit (0.6.2)

* Also requires the wkhtmltopdf libraries:
  gem install wkhtmltopdf-binary
  or
  brew install wkhtmltopdf

  Shouldn't matter how you install it, as long as it responds to the system command 'which wkhtmltopdf' and returns a valid, absolute path. If using rvm gemsets, recommend installing as gem to global gemset.

* Uses git to request user's email. Needs to be modified to be made optional.

== LICENSE:

(The MIT License)

Copyright (c) 2016 Prometheus Computing LLC

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
