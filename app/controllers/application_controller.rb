require_dependency 'dump'

class ApplicationController < ActionController::Base
	include SimpleCaptcha::ControllerHelpers
  def index
		@show_captcha = !Dump.get_upload_permission
  end
	
	def not_found
		render file: "#{Rails.root}/app/views/application/not_found.html.erb", status: 404
  end
  
  def internal_error
		render file: "#{Rails.root}/app/views/application/internal_error.html.erb", status: 500
  end
end
