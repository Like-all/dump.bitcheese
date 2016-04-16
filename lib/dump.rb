class Dump
	def self.gen_key(len)
		unvowels = "wrtpsdfghjklzxcvbnm".chars
		vowels = "eyuioa".chars
		key = ""
		len.times do |i|
			if i % 2 == 0
				key << vowels.sample
			else
				key << unvowels.sample
			end
		end
		key
	end
	
	def self.gen_suitable_key(len, tst)
		begin
			key = self.gen_key(len)
		end until tst.call(key)
		key
	end
	
	def self.clean_name(name)
		name.gsub(/[\s\0\/]/, "_")
	end
end