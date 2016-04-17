class Referer < ActiveRecord::Base
	def self.mkreferer(referer_string)
		if agent = Referer.find_by(referer_string: referer_string)
			agent
		else
			UserAgent.new(referer_string: referer_string)
		end
	end
end
