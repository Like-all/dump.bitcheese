class Dump
	VOWELS = 'wrtpsdfghjklzxcvbnm'.chars.freeze
	CONSONANTS = 'eyuioa'.chars.freeze

	def self.gen_key(len)
		Array.new(len) { |i| i.even? ? VOWELS.sample : CONSONANTS.sample }.join
	end
	
	def self.gen_suitable_key(len, tst)
		begin
			key = self.gen_key(len)
		end until tst.call(key)
		key
	end
	
	def self.clean_name(name)
		name.gsub(%r|[\s\0/]|, "_")
	end
	
	def self.get_content_type(filename)
		IO.popen(%w|file -e text -e encoding -e tokens -e cdf  -e compress -e apptype -e elf -e tar -ib| << filename) do |i| i.read end.split(";")[0]
	end
	
	def self.glacier
		Aws::Glacier::Client.new(access_key_id: Settings.glacier.access_key_id, secret_access_key: Settings.glacier.secret_access_key, region: Settings.glacier.region)
	end
	
	def self.get_upload_permission
		Upload.where("created_at > ?", DateTime.now - 1.day).sum(:size) < Settings.daily_upload_limit
	end
	
	def self.get_thaw_permission
		ThawRequest.where("created_at > ?", DateTime.now - 1.day).sum(:size) < Settings.daily_thaw_limit
	end
end
