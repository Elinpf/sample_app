class UsersController < ApplicationController
	def show
		@user = User.find(params[:id])
	end

  def new
		@user = User.new
  end

	# 创建用户
	def create
		@user = User.new(user_params)
		if @user.save

			# 创建用户后，分配cookie 并直接登录
			log_in @user

			# Handle a successful save.
			# 重定向到 user_url(@user)
			flash[:success] = "Welcome to the Sample App!"
			redirect_to @user
		else
			render 'new'
		end
	end

private
	def user_params
		params.require(:user).permit(:name, :email, 
									:password, :password_confirmation )
	end
end
