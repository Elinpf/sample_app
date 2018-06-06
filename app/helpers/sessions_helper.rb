module SessionsHelper
	
	# 创建一个log_in方法
	def log_in(user)
		# ActionDispatch::Request::Session 类
		# 这个类是用来分配Cookie的
		session[:user_id] = user.id
	end

	# 返回现在的用户
	def current_user
		# 用 find_by 的目的是避免出现没有用户的情况下抛出异常
		# 使用 ||= 避免多次访问数据库
		@current_user ||= User.find_by(id: session[:user_id])
	end

	def logged_in?
		!current_user.nil?
	end

	# 登出
	def log_out
		session.delete(:user_id)
		@current_user = nil
	end
end
