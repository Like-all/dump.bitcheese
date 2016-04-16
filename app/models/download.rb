class Download < ActiveRecord::Base
	has_one :user_agent
	has_one :referer
end
