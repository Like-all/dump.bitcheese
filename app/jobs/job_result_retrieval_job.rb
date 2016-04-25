require_dependency 'dump'

class JobResultRetrievalJob < ActiveJob::Base
  queue_as :default

  def perform(dumped_file, job_id)
		glacier = Dump.glacier
		desc = glacier.describe_job(account_id: "-", vault_name: Settings.glacier.vault_name, job_id: job_id)
		if desc.completed
			path = DumpedFile.download_archive(job_id)
			DumpedFile.install_archive(path, dumped_file.filename, dumped_file.file_path)
		else
			JobResultRetrievalJob.delay(run_at: 1.hours.from_now).perform_later(job_id)
		end
  end
end
