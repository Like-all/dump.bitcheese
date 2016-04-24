class CreateFrozenFiles < ActiveRecord::Migration
  def change
    create_table :frozen_files do |t|
      t.string :file_id
      t.integer :dumped_file_id

      t.timestamps null: false
    end
    add_index :frozen_files, :dumped_file_id, unique: true
  end
end
