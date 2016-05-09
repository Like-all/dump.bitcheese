class AddIndexOnHash < ActiveRecord::Migration
  def change
		add_index :dumped_files, :file_hash
  end
end
