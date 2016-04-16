class CreateUploads < ActiveRecord::Migration
	def change
		create_table :uploads do |t|
			t.inet :ip
			t.string :filename
			t.integer :size
			t.integer :user_agent_id

			t.timestamps null: false
		end
		add_index :uploads, :ip
		add_index :uploads, :filename
		add_index :uploads, :created_at
		add_index :uploads, :user_agent_id
	end
end
