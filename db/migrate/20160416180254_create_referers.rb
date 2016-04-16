class CreateReferers < ActiveRecord::Migration
  def change
    create_table :referers do |t|
      t.text :referer_string

      t.timestamps null: false
    end
    add_index :referers, :referer_string, unique: true
  end
end
