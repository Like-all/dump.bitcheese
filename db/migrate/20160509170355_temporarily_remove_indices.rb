class TemporarilyRemoveIndices < ActiveRecord::Migration
  def up
		remove_index :referers, :referer_string
		remove_index :user_agents, :user_agent_string
  end
  
  def down
		add_index :referers, :referer_string, unique: true
		add_index :user_agents, :user_agent_string, unique: true
  end
end
