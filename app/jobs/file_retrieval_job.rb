class FileRetrievalJob < ActiveJob::Base
  queue_as :default

  def perform(dumped_file)
    case Settings.glaciate.way
		when :cp
			d_path = DumpedFile.download_archive(dumped_file.frozen_file.file_id)
			DumpedFile.install_archive(d_path, dumped_file.filename, dumped_file.file_path)
    end
  end
  
  def destroy_failed_jobs?
    true
  end
end
