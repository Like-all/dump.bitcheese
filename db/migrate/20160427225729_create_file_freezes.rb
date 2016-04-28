class CreateFileFreezes < ActiveRecord::Migration
  def change
    create_table :file_freezes do |t|
      t.string :filename
      t.integer :size

      t.timestamps null: false
    end
    add_index :file_freezes, :filename
    add_index :file_freezes, :size
  end
end
