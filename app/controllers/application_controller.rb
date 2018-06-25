class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

	# 因为Sessions模块会用在很多Controller中，所以在这个地方统一include
	include SessionsHelper

	# 确认是在登录状态中
	def logged_in_user
		unless logged_in?
			store_location
			flash[:danger] = "Please log in."
			redirect_to login_url
		end
	end
end
