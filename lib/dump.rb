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
end
