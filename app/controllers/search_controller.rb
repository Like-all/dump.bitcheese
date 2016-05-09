class SearchController < ApplicationController
	def find_by_hash
		return internal_error unless params[:hash].size == 128
		@file = DumpedFile.find_by_readable_hash(params[:hash])
		return not_found unless @file
		if request.query_string == "simple"
			render plain: URI.parse(request.url).merge(URI.parse(dumped_file_path(@file)))
		else
			redirect_to dumped_file_preview_path(@file)
		end
	end
end
