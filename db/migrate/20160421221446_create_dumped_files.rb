class CreateDumpedFiles < ActiveRecord::Migration
  def change
    create_table :dumped_files do |t|
      t.datetime :accessed_at
      t.boolean :file_frozen, default: false
      t.string :filename
      t.integer :size

      t.timestamps null: false
    end
    add_index :dumped_files, :filename, unique: true
    add_index :dumped_files, :accessed_at
    add_index :dumped_files, :size
  end
end
