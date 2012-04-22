module ApplicationHelper
	def n(user)
		if user.nil?
			return "Anonymous"
		else
			return user.nickname
		end
	end
end
