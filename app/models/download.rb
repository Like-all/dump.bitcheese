class Download < ActiveRecord::Base
	belongs_to :user_agent
	belongs_to :referer
end
