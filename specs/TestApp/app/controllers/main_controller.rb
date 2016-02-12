# The Main Controller deals with generating application-wide pages that are not specific
# to data contained within the application database.  The functionality supported includes
# generation of the home page as well as error handling
class MainController < ApplicationController
  # The home module defines data for the application home page.  Routing definitions point
  # all root requests to the home module
  def home
  end
end
