class StatsController < ApplicationController
	before_filter :authenticate_admin

	def index
		@obscure_files = DumpedFile.where("file_frozen = false AND accessed_at < ?", DateTime.now - 1.month)
		@very_obscure_files = DumpedFile.where("file_frozen = false AND accessed_at = (SELECT min(accessed_at) FROM dumped_files)")
		@frozen_files = DumpedFile.where(file_frozen: true)
		@live_files = DumpedFile.where(file_frozen: false)
		@uploads_last_day = Upload.where("created_at > ?", DateTime.now - 1.day)
		@downloads_last_day = Download.where("created_at > ?", DateTime.now - 1.day)
		@thawed = ThawRequest
	end
end
