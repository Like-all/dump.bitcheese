class UserAgent < ActiveRecord::Base
	has_many :downloads
	has_many :uploads
	
	def self.obtain(str)
		self.find_by("md5(user_agent_string) = md5(?)", str.to_s) || self.create(user_agent_string: str.to_s)
	end
end
