require_dependency 'dump'

class DumpedFile < ActiveRecord::Base
	has_one :frozen_file
	
	def file_path
		File.join(Settings.dir, self.filename)
	end
	
	def glaciate!
		return false if self.file_frozen?
		out_tmp = Tempfile.new("dump_ep", encoding: 'ascii-8bit')
		in_tmp = Tempfile.new("dump_ec", encoding: 'ascii-8bit')
		in_tmp.write(self.filename)
		in_tmp.write("\0")
		File.open(self.file_path, mode: "rb") do |f|
			until f.eof?
				in_tmp.write f.read(1e6)
			end
		end
		in_tmp.flush
		in_tmp.rewind
		crypto = GPGME::Crypto.new(password: Settings.gpg.passphrase, pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK)
		crypto.encrypt(in_tmp, sign: true, signers: Settings.gpg.key_id, recipients: Settings.gpg.key_id, output: out_tmp)
		out_tmp.close
		file_id = DumpedFile.offload_archive(out_tmp.path)
		self.frozen_file = FrozenFile.new(file_id: file_id)
		self.file_frozen = true
		self.save!
		FileUtils.rm self.file_path
		out_tmp.unlink
		in_tmp.close
		in_tmp.unlink
		FileFreeze.new(filename: self.filename, size: self.size).save!
	end
	
	# Maybe add job to retrieve the file from cold storage
	def thaw!(request)
		return :not_frozen unless self.file_frozen?
		if tr = ThawRequest.find_by(filename: self.filename, finished: false)
			return tr
		end
		if Dump.get_thaw_permission
			ThawRequest.transaction do
				ActiveRecord::Base.connection.execute('LOCK TABLE user_agents,referers IN SHARE MODE')
				thaw_request = ThawRequest.new(filename: self.filename, referer: Referer.find_or_initialize_by(referer_string: request.referer), size: self.size, user_agent: UserAgent.find_or_initialize_by(user_agent_string: request.user_agent), ip: request.remote_ip)
				thaw_request.save!
				FileRetrievalJob.perform_later(self)
				return thaw_request
			end
		else
			return :not_thawing
		end
	end
	
	def mark_thawed!
		self.frozen_file.destroy!
		self.file_frozen = false
	end
	
	# Offloads archive to cold storage
	def self.offload_archive(path)
		case Settings.glaciate.way
		when :cp
			file_id = SecureRandom.hex(50)
			FileUtils.cp path, File.join(Settings.glaciate.target, file_id)
			return file_id
		when :glacier
			glacier = Dump.glacier
			resp = glacier.upload_archive(vault_name: Settings.glacier.vault_name, account_id: "-", body: File.open(path, "rb"))
			return resp.archive_id
		end
	end
	
	# Downloads archive from cold storage
	def self.download_archive(archive_id)
		case Settings.glaciate.way
		when :cp
			tempname = Dir::Tmpname.make_tmpname "dump_da", ""
			FileUtils.cp File.join(Settings.glaciate.target, archive_id), tempname
			return tempname
		when :glacier
			glacier = Dump.glacier
			tempname = Dir::Tmpname.make_tmpname "dump_da", ""
			glacier.get_job_output(account_id: "-", vault_name: Settings.glacier.vault_name, job_id: archive_id, response_target: tempname)
			return tempname
		end
	end
	
	# Verifies and installs archive in path
	def self.install_archive(path, filename, target_path)
		archive = File.open(path, "rb")
		crypto = GPGME::Crypto.new(password: Settings.gpg.passphrase, pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK)
		tmpfile = Tempfile.new("dump_di", encoding: 'ascii-8bit')
		okay = false
		crypto.decrypt(archive, output: tmpfile){ |sig| okay |= (sig.key.fingerprint == Settings.gpg.key_id && sig.valid?) }
		raise "Archive verification failed: #{path}!" unless okay
		tmpfile.rewind
		fname = "".force_encoding('ascii-8bit')
		while fname.size < 256 && (nch = tmpfile.readchar).ord != 0
			fname << nch
		end
		fname = fname.force_encoding("UTF-8")
		raise "Not the same file found in archive #{path}: #{fname} vs #{filename}!" if fname != filename
		tmpfile.seek(fname.bytesize+1)
		File.open(target_path,"wb") do |f|
			until tmpfile.eof?
				f.write tmpfile.read(1e6)
			end
		end
		tmpfile.close
		tmpfile.unlink
		FileUtils.rm path
		df = DumpedFile.find_by(filename: filename)
		df.mark_thawed!
		df.save!
		ThawRequest.where(filename: filename, finished: false).update_all(finished: true)
	end
end
