class DownloadsController < ApplicationController
	before_filter :authenticate_admin
	def index
		@downloads = Download.order("created_at DESC").includes(:user_agent, :referer).page(params[:page]).per(100)
	end
end
