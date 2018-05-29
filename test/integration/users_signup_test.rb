require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
	
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
	end

	test "valid signup information" do
		get signup_path

		# 确认块运行后User.count的不同，并且只有1的不同
		assert_difference 'User.count', 1 do 
			post users_path, params: { user: { name: "Example User",
						email: "user@example.com",
						password: "password", password_confirmation: "password" }}
		end
		# 跟踪页面中的重定向
		follow_redirect!
		# 确认重定向后的返回页面
		assert_template "users/show"
	end

end
