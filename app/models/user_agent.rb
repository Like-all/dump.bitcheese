class UserAgent < ActiveRecord::Base
	has_many :downloads
	has_many :uploads
end
