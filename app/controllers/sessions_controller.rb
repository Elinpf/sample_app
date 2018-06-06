class SessionsController < ApplicationController
  def new
  end

	def create
		# 注意此处是通过查找email找到User的实例
		user = User.find_by(email: params[:session][:email].downcase)

		# 如果找到了实例，就使用 authenticate方法检查密码
		if user and user.authenticate(params[:session][:password])
			# 登录
			# log_in 是 SessionsHelp 模块中的方法
			log_in user
			redirect_to user
		else
			# flash 是一个特定的类， now变量中只渲染一次
			flash.now[:danger] = 'Invalid email/password combination'
			
			# 重新显示new页面
			render 'new'
		end
	end

	# 销毁动作，对应的是routes的DELETE
	def destroy
		log_out
		redirect_to root_path
	end
end
