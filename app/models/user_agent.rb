class UserAgent < ActiveRecord::Base
	def self.mkagent(agent_string)
		if agent = UserAgent.find_by(user_agent_string: agent_string)
			agent
		else
			UserAgent.new(user_agent_string: agent_string)
		end
	end
end
