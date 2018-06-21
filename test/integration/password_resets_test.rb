require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
	
	def setup
		ActionMailer::Base.deliveries.clear
		@user = users(:michael)
	end

	test 'password resets' do 
		get new_password_reset_path
		assert_template 'password_resets/new'
		# 无效的email
		post password_resets_path, params: { password_reset: { 
							email: "" }}
		assert_not flash.empty?
		assert_template 'password_resets/new'

		# 有效的email
		post password_resets_path, params: { password_reset: {
							email: @user.email }}
		assert_not_equal @user.reset_digest, @user.reload.reset_digest
		assert_equal 1, ActionMailer::Base.deliveries.size
		assert_not flash.empty?
		assert_redirected_to root_url

		# 重置密码的格式
		user = assigns(:user)

		# 错误的Email
		get edit_password_reset_path(user.reset_token, email: "")
		assert_redirected_to root_url

		# 无效的用户
		user.toggle!(:activated)
		get edit_password_reset_path(user.reset_token, email: user.email)
		assert_redirected_to root_url
		user.toggle!(:activated)

		# 正确的Email, 错误的token
		get edit_password_reset_path("wrong token", email: user.email)
		assert_redirected_to root_url

		# 正确的Email, 正确的token
		get edit_password_reset_path(user.reset_token, email: user.email)
		assert_template 'password_resets/edit'
		# <input id="email" name="email" type="hidden" value="michael@example.com" />
		assert_select 'input[name=email][type=hidden][value=?]', user.email

		# 无效的密码和确认密码
		patch password_reset_path(user.reset_token),
							params: {email: user.email,
								user: { password: "foobaz",
									password_confirmation: "barquux" } }
		assert_select 'div#error_explanation'
		
		# 空密码
		patch password_reset_path(user.reset_token),
						params: { email: user.email,
							user: { password: "", password_confirmation: "" }}
		assert_select 'div#error_explanation'

		# 有效的密码和确认密码
		patch password_reset_path(user.reset_token),
						params: { email: user.email,
							user: { password: "foobar",
											password_confirmation: "foobar" } }
		assert is_logged_in?
		assert_not flash.empty?
		assert_redirected_to user
	end
end
