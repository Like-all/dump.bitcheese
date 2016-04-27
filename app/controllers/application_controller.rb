require_dependency 'dump'

class ApplicationController < ActionController::Base
	include SimpleCaptcha::ControllerHelpers
  def index
		@show_captcha = !Dump.get_upload_permission
  end
end
