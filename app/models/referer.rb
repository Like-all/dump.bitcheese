class Referer < ActiveRecord::Base
	has_many :downloads	
	def distinct_downloads
		self.downloads.group("filename").count
	end
end
