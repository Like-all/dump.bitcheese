class UploadsController < ApplicationController
	before_filter :authenticate_admin
	def index
		@uploads = Upload.order("created_at DESC").includes(:user_agent).page(params[:page]).per(100)
	end
end
