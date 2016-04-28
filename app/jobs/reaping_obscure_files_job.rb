class ReapingObscureFilesJob < ActiveJob::Base
	queue_as :default

	def perform
		while DumpedFile.where(file_frozen: false).sum(:size) > Settings.storage_limit
			victim = DumpedFile.where(file_frozen: false).order("accessed_at ASC").first(5).sample
			victim.glaciate!
		end
	end
end
