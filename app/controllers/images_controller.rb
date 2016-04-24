require_dependency 'dump'

class ImagesController < ApplicationController
	def upload
		uploaded = params[:file]
		if !uploaded.is_a? ActionDispatch::Http::UploadedFile
			flash[:error] = "This is not a file"
			redirect_to root_url
		elsif uploaded.size > Settings.max_image_size
			flash[:error] = "File is too big!"
			redirect_to root_url
		else
			image = Magick::ImageList.new(uploaded.tempfile.path)
			unless ["PNG", "JPEG", "GIF"].include? image.format
				flash[:error] = "Suspicious image format"
				redirect_to root_url
			end
			cleaned_name = Dump.clean_name(uploaded.original_filename)
			file_key = Dump.gen_suitable_key(Settings.key_size, lambda do |f| !File.exists?(File.join(Settings.dir, "images", f, cleaned_name)) end)
			file_name = File.join(Settings.dir, "images", file_key, cleaned_name)
			FileUtils.mkdir_p File.join(Settings.dir, "images", file_key)
			File.open(file_name, "wb") do |f| f.write uploaded.read end
			# Success! Log it.
			u = Upload.new
			u.ip = request.remote_ip
			u.filename = File.join("images", file_key, cleaned_name)
			u.user_agent = UserAgent.mkagent(request.user_agent)
			u.size = uploaded.size
			u.save!
			f = DumpedFile.find_or_initialize_by(filename: u.filename)
			f.size = uploaded.size
			f.accessed_at = DateTime.now
			f.save!
			if request.query_string == "simple"
				render plain: url_for(controller: "images", action: "download", slug: file_key, filename: cleaned_name, only_path: false)
			else
				redirect_to url_for(controller: "images", action: "preview", slug: file_key, filename: cleaned_name)
			end
		end
	end
	
	def preview
		@slug = Dump.clean_name(params[:slug])
		@filename = Dump.clean_name(params[:filename])
		@size = File.size("#{Settings.dir}/images/#{Dump.clean_name(params[:slug].to_s)}/#{Dump.clean_name(params[:filename])}")
		@image_path = url_for(controller: :images, action: :download, slug: @slug, filename: @filename, only_path: false)
		@thumb_path = url_for(controller: :images, action: :thumb, slug: @slug, filename: @filename, only_path: false)
	end
	
	def download
		filename = File.join(Settings.dir, "images", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename]))
		raise ActionController::RoutingError.new('Not Found') unless File.exists? filename
		u = Download.new
		u.ip = request.remote_ip
		u.filename = File.join("images", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename]))
		u.user_agent = UserAgent.mkagent(request.user_agent)
		u.referer = Referer.mkreferer(request.referer)
		u.size = File.size(filename)
		u.save!
		f = DumpedFile.find_or_initialize_by(filename: u.filename)
		f.size = File.size(filename)
		f.accessed_at = DateTime.now
		f.save!
		send_file filename, x_sendfile: true, disposition: "inline", type: Dump.get_content_type(filename)
	end
	
	def thumb
		filename = "#{Settings.dir}/images/#{Dump.clean_name(params[:slug].to_s)}/#{Dump.clean_name(params[:filename])}"
		raise ActionController::RoutingError.new('Not Found') unless File.exists? filename
		thumb_name = "#{Settings.dir}/images/#{Dump.clean_name(params[:slug].to_s)}/thumb/#{Dump.clean_name(params[:filename])}"
		if !File.exists? thumb_name
			# Create thumb
			image = Magick::ImageList.new(filename)
			image.resize_to_fit!(Settings.thumb_width, Settings.thumb_height)
			FileUtils.mkdir_p "#{Settings.dir}/images/#{Dump.clean_name(params[:slug].to_s)}/thumb"
			image.write(thumb_name)
		end
		if !request.referer.to_s.start_with?(root_url(only_path: false))
			u = Download.new
			u.ip = request.remote_ip
			u.filename = File.join("images", Dump.clean_name(params[:slug].to_s), "thumb", Dump.clean_name(params[:filename]))
			u.user_agent = UserAgent.mkagent(request.user_agent)
			u.referer = Referer.mkreferer(request.referer)
			u.size = File.size(filename)
			u.save!
		end
		f = DumpedFile.find_or_initialize_by(filename: File.join("images", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename])))
		f.size = File.size(filename)
		f.accessed_at = DateTime.now
		f.save!
		send_file thumb_name, x_sendfile: true, disposition: "inline", type: Dump.get_content_type(thumb_name)
	end
end
