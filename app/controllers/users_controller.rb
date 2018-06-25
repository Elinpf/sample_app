class UsersController < ApplicationController
	# 前提动作，防止未登录的用户操作
	before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
	before_action :correct_user, only: [:edit, :update]
	before_action :admin_user, only: :destroy

	def index
		# 分页输出, 默认一次性输出30个
		@users = User.paginate(page: params[:page])
	end

	def show
		@user = User.find(params[:id])
		# 从Get中获取page参数,分组发送给@microposts
		@microposts = @user.microposts.paginate(page: params[:page])
	end

  def new
		@user = User.new
  end

	# 创建用户
	def create
		@user = User.new(user_params)
		if @user.save
			@user.send_activation_email
			flash[:info] = "Please check your email to activate your account."
			redirect_to root_url
		else
			render 'new'
		end
	end

	def edit
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])

		# 判断是否更新成功,同样也要依据 models/user 中的规定
		if @user.update_attributes(user_params)
			# 成功的更新
			flash[:success] = "Profile update"
			redirect_to @user
		else 
			render 'edit'
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User delete"
		redirect_to users_url
	end


private
	# 安全的获取方式
	def user_params
		params.require(:user).permit(:name, :email, 
									:password, :password_confirmation )
	end
	
	# 提前过滤


	def correct_user
		@user = User.find(params[:id])
		redirect_to root_path unless current_user?(@user)
	end

	# 当不是管理员的时候使用destroy时强制返回
	def admin_user
		redirect_to(root_url) unless current_user.admin?
	end
end
