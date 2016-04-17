class Referer < ActiveRecord::Base
	has_many :downloads
	def self.mkreferer(referer_string)
		if agent = Referer.find_by(referer_string: referer_string)
			agent
		else
			Referer.new(referer_string: referer_string)
		end
	end
end
