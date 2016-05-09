class AddHashToDumpedFiles < ActiveRecord::Migration
  def change
    add_column :dumped_files, :file_hash, :binary, limit: 64
  end
end
