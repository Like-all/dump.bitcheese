class CreateThawRequests < ActiveRecord::Migration
  def change
    create_table :thaw_requests do |t|
      t.string :filename
      t.integer :size
      t.integer :referer_id
      t.integer :user_agent_id
      t.inet :ip
      t.boolean :finished, default: false

      t.timestamps null: false
    end
    add_index :thaw_requests, :filename
    add_index :thaw_requests, :size
    add_index :thaw_requests, :referer_id
    add_index :thaw_requests, :user_agent_id
    add_index :thaw_requests, :ip
  end
end
