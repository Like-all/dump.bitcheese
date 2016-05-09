class AddHashIndices < ActiveRecord::Migration
  def down
		remove_index :referers, :referer_string
		remove_index :user_agents, :user_agent_string
  end
  
  def up
		execute <<-SQL
			CREATE INDEX index_referers_on_referer_string ON referers( md5(referer_string) );
		SQL
		execute <<-SQL
			CREATE INDEX index_user_agents_on_user_agent_string ON user_agents( md5(user_agent_string) );
		SQL
  end
end
