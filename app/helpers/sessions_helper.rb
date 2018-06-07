module SessionsHelper
	
	# 创建一个log_in方法
	def log_in(user)
		# ActionDispatch::Request::Session 类
		# 这个类是用来分配Cookie的
		session[:user_id] = user.id
	end

	# 为 controllers/session_controller 模块提供方法
	def remember(user)
		# models/user 中的方法
		user.remember
		
		# NOTE cookies 是Rials的类，后面需要学习
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	# 忘记用户的登录token
	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end

	# 返回现在的用户
	def current_user
		# 当有session时使用session
		if (user_id = session[:user_id])
			# 用 find_by 的目的是避免出现没有用户的情况下抛出异常
			# 使用 ||= 避免多次访问数据库
			@current_user ||= User.find_by(id: user_id)

		# 当是记住的token时使用cookies
		elsif (user_id = cookies.signed[:user_id])
			user = User.find_by(id: user_id)
			if user and user.authenticated?(cookies[:remember_token])
				log_in user
				@current_user = user
			end
		end
	end

	def logged_in?
		!current_user.nil?
	end

	# 登出
	def log_out
		# 忘记token
		forget(current_user)
		
		# 删除session
		session.delete(:user_id)
		@current_user = nil
	end
end
