require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

	def setup
		# 清空所有邮箱信息
		ActionMailer::Base.deliveries.clear
	end
	
	test "invalid signup information" do
		get signup_path
		 
		# 比较现在与执行完之后 User.count 的不同
		assert_no_difference 'User.count' do
			# 以POST的方式发送到users_path
			post users_path, params: { user: { name: "",
					email: "user@invalid",
					password: "foo", password_confirmation: "bar" } }
		end
		# 确认返回页面
		assert_template 'users/new'
		assert_select 'div#error_explanation'
		assert_select 'div.field_with_errors'
	end

	test 'vaild signup information with account activation' do
		get signup_path
		assert_difference 'User.count', 1 do
			post users_path, params: { user: { name: "Example User",
						email: "user@example.com",
						password: "password", password_confirmation: "password" } }
		end
		assert_equal 1, ActionMailer::Base.deliveries.size
		user = assigns(:user)
		assert_not user.activated?
		# 向尝试登录
		log_in_as(user)
		assert_not is_logged_in?
		# 无效的activation token
		get edit_account_activation_path("invalid token", email: user.email)
		assert_not is_logged_in?
		# 有效的token, 错误的email
		get edit_account_activation_path(user.activation_token, email: "worng")
		assert_not is_logged_in?
		# 有效的token
		get edit_account_activation_path(user.activation_token,
				 email: user.email)
		assert user.reload.activated?
		follow_redirect!
		assert_template 'users/show'
		assert is_logged_in?
	end
end
