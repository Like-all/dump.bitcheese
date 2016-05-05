require_dependency 'dump'

class ApplicationController < ActionController::Base
	include SimpleCaptcha::ControllerHelpers
  def index
		@show_captcha = !Dump.get_upload_permission
  end
	
	def not_found
		render controller: "application", action: "not_found", status: 404
  end
  
  def internal_error
		render status: 500
  end
end
