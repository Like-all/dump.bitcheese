class ThawRequest < ActiveRecord::Base
	belongs_to :referer
	belongs_to :user_agent
end
