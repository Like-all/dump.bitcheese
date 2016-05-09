require_dependency 'dump'

class FilesController < ApplicationController
	def upload
		uploaded = params[:file]
		if !Dump.get_upload_permission && !simple_captcha_valid?
			flash[:error] = "Please input correct captcha"
			redirect_to root_url
		elsif !uploaded.is_a? ActionDispatch::Http::UploadedFile
			flash[:error] = "This is not a file"
			redirect_to root_url
		elsif uploaded.size > Settings.max_file_size
			flash[:error] = "File is too big!"
			redirect_to root_url
		else
			cleaned_name = Dump.clean_name(uploaded.original_filename)
			file_key = Dump.gen_suitable_key(Settings.key_size, lambda do |f| !File.exists?(File.join(Settings.dir, "files", f, cleaned_name)) end)
			file_name = File.join(Settings.dir, "files", file_key, cleaned_name)
			FileUtils.mkdir_p File.join(Settings.dir, "files", file_key)
			File.open(file_name, "wb") do |f| f.write uploaded.read end
			# Success! Log it.
			Upload.transaction do
				ActiveRecord::Base.connection.execute("LOCK TABLE uploads, user_agents, dumped_files IN SHARE ROW EXCLUSIVE MODE")
				u = Upload.new
				u.ip = request.remote_ip
				u.filename = File.join("files", file_key, cleaned_name)
				u.user_agent = UserAgent.obtain(request.user_agent)
				u.size = uploaded.size
				u.save!
				f = DumpedFile.find_or_initialize_by(filename: u.filename)
				f.size = uploaded.size
				f.accessed_at = DateTime.now
				f.save!
			end
			if request.query_string == "simple"
				render plain: url_for(controller: "files", action: "download", slug: file_key, filename: cleaned_name, only_path: false)
			else
				redirect_to url_for(controller: "files", action: "preview", slug: file_key, filename: cleaned_name)
			end
		end
	end
	
	def preview
		@slug = Dump.clean_name(params[:slug].to_s)
		@filename = Dump.clean_name(params[:filename])
		@size = File.size("#{Settings.dir}/files/#{Dump.clean_name(params[:slug].to_s)}/#{Dump.clean_name(params[:filename])}")
	end
	
	def download
		fname = File.join("files", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename]))
		filename = File.join(Settings.dir, "files",Dump.clean_name(params[:slug].to_s),Dump.clean_name(params[:filename]))
		Download.transaction do
			ActiveRecord::Base.connection.execute("LOCK TABLE downloads, user_agents, referers, thaw_requests, dumped_files IN SHARE ROW EXCLUSIVE MODE")
			f = DumpedFile.find_or_initialize_by(filename: fname)
			if !File.file?(filename) && f.file_frozen
				@thaw_request = f.thaw!(request)
				return(render('files/thawin', status: 503))
			elsif f.file_frozen
				f.mark_thawed!
				ThawRequest.where(filename: fname, finished: false).update_all(finished: true)
			elsif !File.file?(filename) 
				return not_found
			end
			if !request.referer.to_s.start_with?(root_url(only_path: false))
				u = Download.new
				u.ip = request.remote_ip
				u.filename = fname
				u.user_agent = UserAgent.obtain(request.user_agent)
				u.referer = Referer.obtain(request.referer)
				u.size = File.size(filename)
				u.save!
			end
			
			f.size = File.size(filename)
			f.accessed_at = DateTime.now
			f.save!
		end
		send_file filename, x_sendfile: true, disposition: "inline", type: Dump.get_content_type(filename)
	end
end
