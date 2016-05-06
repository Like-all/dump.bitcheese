class ReferersController < ApplicationController
	before_filter :authenticate_admin
	
	def index
		@referers = Referer.where({})
	end
end
