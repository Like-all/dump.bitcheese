class Referer < ActiveRecord::Base
	has_many :downloads	
	def distinct_downloads
		self.downloads.group("filename").count
	end
	
	def self.obtain(str)
		self.find_by("md5(referer_string) = md5(?)", str.to_s) || self.create(referer_string: str.to_s)
	end
end
