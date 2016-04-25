require_dependency 'dump'

class FileRetrievalJob < ActiveJob::Base
  queue_as :default

  def perform(dumped_file)
    case Settings.glaciate.way
		when :cp
			d_path = DumpedFile.download_archive(dumped_file.frozen_file.file_id)
			DumpedFile.install_archive(d_path, dumped_file.filename, dumped_file.file_path)
		when :glacier
			glacier = Dump.glacier
			job = glacier.initiate_job(account_id: "-", vault_name: Settings.glacier.vault_name, job_parameters: {type: "archive-retrieval", archive_id: dumped_file.frozen_file.file_id})
			JobResultRetrievalJob.delay(run_at: 1.hours.from_now).perform_later(dumped_file, job.job_id)
    end
  end
  
  def destroy_failed_jobs?
    true
  end
end
