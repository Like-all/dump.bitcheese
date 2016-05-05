require_dependency 'dump'

class ImagesController < ApplicationController
	def upload
		return not_found
		uploaded = params[:file]
		if !Dump.get_upload_permission && !simple_captcha_valid?
			flash[:error] = "Please input correct captcha"
			redirect_to root_url
		elsif !uploaded.is_a? ActionDispatch::Http::UploadedFile
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
			Upload.transaction do
				ActiveRecord::Base.connection.execute("LOCK TABLE uploads, user_agents, dumped_files IN SHARE ROW EXCLUSIVE MODE")
				u = Upload.new
				u.ip = request.remote_ip
				u.filename = File.join("images", file_key, cleaned_name)
				u.user_agent = UserAgent.find_or_create_by(user_agent_string: request.user_agent)
				u.size = uploaded.size
				u.save!
				f = DumpedFile.find_or_initialize_by(filename: u.filename)
				f.size = uploaded.size
				f.accessed_at = DateTime.now
				f.save!
			end
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
		fname = File.join("images", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename]))
		Download.transaction do
			ActiveRecord::Base.connection.execute("LOCK TABLE downloads, user_agents, referers, thaw_requests, dumped_files IN SHARE ROW EXCLUSIVE MODE")
			f = DumpedFile.find_or_initialize_by(filename: fname)
			
			if !File.exists?(filename) && f.file_frozen
				@thaw_request = f.thaw!(request)
				return(render('files/thawin', status: 503))
			elsif f.file_frozen
				f.mark_thawed!
				ThawRequest.where(filename: fname, finished: false).update_all(finished: true)
			elsif !File.exists?(filename) 
				return not_found
			end
				u = Download.new
				u.ip = request.remote_ip
				u.filename = fname
				u.user_agent = UserAgent.find_or_create_by(user_agent_string: request.user_agent)
				u.referer = Referer.find_or_create_by(referer_string: request.referer)
				u.size = File.size(filename)
				u.save!
				
				f.size = File.size(filename)
				f.accessed_at = DateTime.now
				f.save!
		end
		send_file filename, x_sendfile: true, disposition: "inline", type: Dump.get_content_type(filename)
	end
	
	def thumb
		filename = "#{Settings.dir}/images/#{Dump.clean_name(params[:slug].to_s)}/#{Dump.clean_name(params[:filename])}"
		fname = File.join("images", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename]))
		return not_found unless File.exists? filename
		thumb_name = "#{Settings.dir}/images/#{Dump.clean_name(params[:slug].to_s)}/thumb/#{Dump.clean_name(params[:filename])}"
		Download.transaction do
			ActiveRecord::Base.connection.execute("LOCK TABLE downloads, user_agents, referers, thaw_requests, dumped_files IN SHARE ROW EXCLUSIVE MODE")
			f = DumpedFile.find_or_initialize_by(filename: fname)
			
			if !File.exists?(filename) && f.file_frozen
				@thaw_request = f.thaw!(request)
				return(render('files/thawin', status: 503))
			elsif f.file_frozen
				f.mark_thawed!
				ThawRequest.where(filename: fname, finished: false).update_all(finished: true)
			elsif !File.exists?(filename) 
				return not_found
			end
			
			if !File.exists? thumb_name
				return not_found
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
				u.user_agent = UserAgent.find_or_create_by(user_agent_string: request.user_agent)
				u.referer = Referer.find_or_create_by(referer_string: request.referer)
				u.size = File.size(filename)
				u.save!
			end
			
			f.size = File.size(filename)
			f.accessed_at = DateTime.now
			f.save!
		end
		send_file thumb_name, x_sendfile: true, disposition: "inline", type: Dump.get_content_type(thumb_name)
	end
end
