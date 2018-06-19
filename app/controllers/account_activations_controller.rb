class AccountActivationsController < ApplicationController
	# 使用 edit 来验证来自邮件的地址
	def edit
		user = User.find_by(email: params[:email])
		if user and !user.activated? and user.authenticated?(:activation, params[:id])
			user.activate
			log_in user
			flash[:success] = "Account activated!"
			redirect_to user
		else
			flash[:danger] = "Invalid activation link"
			redirect_to root_url
		end
	end
end
