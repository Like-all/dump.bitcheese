class DumpedFile < ActiveRecord::Base
	has_one :frozen_file
	
	def file_path
		File.join(Settings.dir, self.filename)
	end
	
	def glaciate!
		return false if self.file_frozen?
		out_tmp = Tempfile.new("dump", encoding: 'ascii-8bit')
		in_tmp = Tempfile.new("dump", encoding: 'ascii-8bit')
		in_tmp.write(self.filename)
		in_tmp.write("\0")
		in_tmp.write(File.read(self.file_path, mode: "rb"))
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
	end
	
	# Add job to retrieve the file from cold storage
	def thaw!
		return false unless self.file_frozen?
		FileRetrievalJob.perform_later(filename)
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
		end
	end
	
	# Downloads archive from cold storage
	def self.download_archive(archive_id)
		case Settings.glaciate.way
		when :cp
			tempname = Dir::Tmpname.make_tmpname "dump", ""
			FileUtils.cp File.join(Settings.glaciate.target, archive_id), tempname
			return tempname
		end
	end
	
	# Verifies and installs archive in path
	def self.install_archive(path, filename, target_path)
		archive = File.open(path, "rb")
		crypto = GPGME::Crypto.new(password: Settings.gpg.passphrase, pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK)
		tmpfile = Tempfile.new("dump", encoding: 'ascii-8bit')
		okay = false
		crypto.verify(archive, output: tmpfile){ |sig| okay |= (sig.key.fingerprint == Settings.gpg.key_id && sig.valid?) }
		raise "Archive verification failed: #{path}!" unless okay
		tmpfile.rewind
		fname = tmpfile.read.split("\0")[0]
		raise "Not the same file found in archive #{path}: #{fname} vs #{filename}!" if fname != filename
		tmpfile.seek(fname.size+1)
		File.open(target_path,"wb") do |f| f.write tmpfile.read end
		tmpfile.close
		tmpfile.unlink
	end
end
