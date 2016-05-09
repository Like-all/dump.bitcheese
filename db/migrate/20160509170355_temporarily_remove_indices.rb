class TemporarilyRemoveIndices < ActiveRecord::Migration
  def up
		remove_index :referers, :referer_string
		remove_index :user_agents, :user_agent_string
  end
end
