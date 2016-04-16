class CreateUserAgents < ActiveRecord::Migration
  def change
    create_table :user_agents do |t|
      t.text :user_agent_string

      t.timestamps null: false
    end
    add_index :user_agents, :user_agent_string, unique: true
  end
end
