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
			redirect_to url_for(controller: "files", action: "preview", slug: file_key, filename: cleaned_name)
		end
	end
	
	def preview
		@slug = Dump.clean_name(params[:slug].to_s)
		@filename = Dump.clean_name(params[:filename])
		@size = File.size("#{Settings.dir}/files/#{Dump.clean_name(params[:slug].to_s)}/#{Dump.clean_name(params[:filename])}")
	end
	
	def download
		filename = "#{Settings.dir}/files/#{Dump.clean_name(params[:slug].to_s)}/#{Dump.clean_name(params[:filename])}"
		raise ActionController::RoutingError.new('Not Found') unless File.exists? filename
		u = Download.new
		u.ip = request.remote_ip
		u.filename = File.join("files", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename]))
		u.user_agent = UserAgent.mkagent(request.user_agent)
		u.referer = Referer.mkreferer(request.referer)
		u.size = File.size(filename)
		u.save!
		send_file filename, x_sendfile: true
	end
end
