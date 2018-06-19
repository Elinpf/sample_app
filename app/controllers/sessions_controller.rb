class SessionsController < ApplicationController
  def new
  end

	def create
		# 注意此处是通过查找email找到User的实例
		user = User.find_by(email: params[:session][:email].downcase)

		# 如果找到了实例，就使用 authenticate方法检查密码
		if user and user.authenticate(params[:session][:password])
			# 登录
			if user.activated?
				# log_in 是 helpers/sessions_helper 模块中的方法
				log_in user
				# remember 是在 helpers/sessions_helper 中的方法
				params[:session][:remember_me] == '1' ? remember(user) : forget(user)
				# 换回之前保存的地方或者默认user
				redirect_back_or user
			else
				message = "Account not activated."
				message += "Chenk your email for the activation."
				flash[:warning] = message
				redirect_to root_url
			end
		else
			# flash 是一个特定的类， now变量中只渲染一次
			flash.now[:danger] = 'Invalid email/password combination'
			
			# 重新显示new页面
			render 'new'
		end
	end

	# 销毁动作，对应的是routes的DELETE
	def destroy
		log_out if logged_in?
		redirect_to root_path
	end
end
