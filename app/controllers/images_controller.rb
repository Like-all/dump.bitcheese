require_dependency 'dump'

class ImagesController < ApplicationController
	FORMATS = ["image/png", "image/jpeg", "image/gif"]
	
	def upload
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
			hash_of_file = Digest::SHA512.file(uploaded.path).digest
			if file = DumpedFile.find_by(file_hash: hash_of_file, size: uploaded.size)
				if request.query_string == "simple"
					render plain: URI.parse(request.url).merge(URI.parse(dumped_file_path(file)))
				else
					redirect_to dumped_file_preview_path(file)
				end
			else
				content_type = Dump.get_content_type(uploaded.path, file_only: true)
				
				unless FORMATS.include? content_type
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
					u.user_agent = UserAgent.obtain(request.user_agent)
					u.size = uploaded.size
					u.save!
					f = DumpedFile.find_or_initialize_by(filename: u.filename)
					f.size = uploaded.size
					f.file_hash = Digest::SHA512.file(f.file_path).digest
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
	end
	
	def preview
		@slug = Dump.clean_name(params[:slug])
		@filename = Dump.clean_name(params[:filename])
		@dumped_file = DumpedFile.find_by(filename: "images/#{@slug ? @slug + "/" : ""}#{@filename}")
		return not_found unless @dumped_file
		@image_path = url_for(controller: :images, action: :download, slug: @slug, filename: @filename, only_path: false)
		@thumb_path = url_for(controller: :images, action: :thumb, slug: @slug, filename: @filename, only_path: false)
	end
	
	def download
		filename = File.join(Settings.dir, "images", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename]))
		fname = File.join("images", Dump.clean_name(params[:slug].to_s), Dump.clean_name(params[:filename]))
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
				u = Download.new
				u.ip = request.remote_ip
				u.filename = fname
				u.user_agent = UserAgent.obtain(request.user_agent)
				u.referer = Referer.obtain(request.referer)
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
		return not_found unless File.file? filename
		thumb_name = "#{Settings.dir}/images/#{Dump.clean_name(params[:slug].to_s)}/thumb/#{Dump.clean_name(params[:filename])}"
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
			
			if !File.file? thumb_name
				content_type = Dump.get_content_type(filename, file_only: true)
				
				unless FORMATS.include? content_type
					flash[:error] = "Suspicious image format"
					redirect_to root_url
				end
				FileUtils.mkdir_p "#{Settings.dir}/images/#{Dump.clean_name(params[:slug].to_s)}/thumb"
				image = FastImage.new(filename)
				if image.size[0] <= Settings.thumb_width && image.size[1] <= Settings.thumb_height
					FileUtils.copy(filename, thumb_name)
				else
					newx, newy = if image.size[0].to_f / Settings.thumb_width.to_f > image.size[1].to_f / Settings.thumb_height.to_f
						[Settings.thumb_width, (image.size[1].to_f / (image.size[0].to_f / Settings.thumb_width.to_f)).to_i]
					else
						[(image.size[0].to_f / (image.size[1].to_f / Settings.thumb_height.to_f)).to_i, Settings.thumb_height]
					end
					
					FastImage.resize(filename, newx, newy, outfile: thumb_name)
				end
			end
		
			if !request.referer.to_s.start_with?(root_url(only_path: false))
				u = Download.new
				u.ip = request.remote_ip
				u.filename = File.join("images", Dump.clean_name(params[:slug].to_s), "thumb", Dump.clean_name(params[:filename]))
				u.user_agent = UserAgent.obtain(request.user_agent)
				u.referer = Referer.obtain(request.referer)
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
