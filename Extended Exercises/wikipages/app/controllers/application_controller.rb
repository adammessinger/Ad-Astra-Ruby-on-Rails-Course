class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # TEMP: disabling for easier local dev
  protect_from_forgery with: :exception
end
