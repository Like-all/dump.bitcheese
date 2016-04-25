require_dependency 'dump'

class FilesController < ApplicationController
	def upload
		uploaded = params[:file]
		if !uploaded.is_a? ActionDispatch::Http::UploadedFile
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
			u = Upload.new
			u.ip = request.remote_ip
			u.filename = File.join("files", file_key, cleaned_name)
			u.user_agent = UserAgent.mkagent(request.user_agent)
			u.size = uploaded.size
			u.save!
			f = DumpedFile.find_or_initialize_by(filename: u.filename)
			f.size = uploaded.size
			f.accessed_at = DateTime.now
			f.save!
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
		f = DumpedFile.find_or_initialize_by(filename: fname)
		if !File.exists?(filename) && f.file_frozen
			if DumpedFile.find_by(filename: fname, file_frozen: true)
				unless @thaw_request = ThawRequest.find_by(filename: fname, finished: false)
					@thaw_request = ThawRequest.new(filename: fname, referer: Referer.mkreferer(request.referer), size: f.size, user_agent: UserAgent.mkagent(request.user_agent), ip: request.remote_ip)
					@thaw_request.save!
					FileRetrievalJob.perform_later(f)
				end
				return(render('files/thawin', status: 503))
			end
		elsif f.file_frozen
			f.mark_thawed!
			ThawRequest.where(filename: fname, finished: false).update_all(finished: true)
		elsif !File.exists?(filename) 
			raise ActionController::RoutingError.new('Not Found')
		end
		if !request.referer.to_s.start_with?(root_url(only_path: false))
			u = Download.new
			u.ip = request.remote_ip
			u.filename = fname
			u.user_agent = UserAgent.mkagent(request.user_agent)
			u.referer = Referer.mkreferer(request.referer)
			u.size = File.size(filename)
			u.save!
		end
		
		f.size = File.size(filename)
		f.accessed_at = DateTime.now
		f.save!
		send_file filename, x_sendfile: true, disposition: "inline", type: Dump.get_content_type(filename)
	end
end
