class ReferersController < ApplicationController
	before_filter :digest_authenticate

	def digest_authenticate

		authenticate_or_request_with_http_digest("Statistics") do |username|
			Settings.stats_password
		end
	end
	
	def index
		@referers = Referer.where({})
	end
end
