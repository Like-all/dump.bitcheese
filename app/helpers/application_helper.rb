module ApplicationHelper
	def filesize_to_style(sz)
		if sz < 1e6
			return "smallfile"
		elsif sz < 10e6
			return "medfile"
		elsif sz < 61e6
			return "bigefile"
		else
			return "hugefile"
		end
	end
	
	def thawed_to_style(thawed)
		thawed ? "thawed" : "not-thawed"
	end
end
