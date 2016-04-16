class CreateDownloads < ActiveRecord::Migration
	def change
		create_table :downloads do |t|
			t.inet :ip
			t.string :filename
			t.integer :size
			t.integer :referer_id
			t.integer :user_agent_id

			t.timestamps null: false
		end
		add_index :downloads, :ip
		add_index :downloads, :filename
		add_index :downloads, :referer_id
		add_index :downloads, :user_agent_id
	end
end
