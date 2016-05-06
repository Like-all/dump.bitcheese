class ThawRequestsController < ApplicationController
	before_filter :authenticate_admin
	def index
		@thaw_requests = ThawRequest.order("created_at DESC").page(params[:page]).per(100)
	end
end
