require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
	# 在开始之前确认@user, 而这个:michael 在test/fixtures/users.yml中定义
	def setup
		@user = users(:michael)
	end
	
	# 测试无效用户
	test 'login with invalid information' do
		get login_path
		assert_template 'sessions/new'
		post login_path, params: { session: { email: "", password: "" }}
		assert_template 'sessions/new'
		# flash 标语是否为空
		assert_not flash.empty?
		# 重新回到根目录
		get root_path
		# 再看 flash 标语是否为空
		assert flash.empty?
	end

  # 测试有效用户
	test 'login with valid information' do
		get login_path
		assert_template 'sessions/new'
		# @user 为 setup 定义的用户
		post login_path, params: { session: { email: @user.email,
	 										password: 'password' } }
		# 是否跳转到 user_path(@user) 地址
		assert_redirected_to @user
		# 跟踪跳转
		follow_redirect!
		assert_template 'users/show'
		# 确定没有 login 链接
		assert_select "a[href=?]", login_path, count: 0
		assert_select "a[href=?]", logout_path
		assert_select "a[href=?]", user_path(@user)

		# 判断是否登录
		# session 中的helper方法不能在这里使用
		# 所以在test/test_helper.rb 中加入is_logged_in? 方法, 并且取名有点不同
		assert is_logged_in?
	end 

	test 'login with valid information followed by logout' do
		get login_path
		post login_path, params: { session: { email: @user.email,
							password: 'password' } }
		assert is_logged_in?
		assert_redirected_to @user
		follow_redirect!
		assert_template 'users/show'
		assert_select "a[href=?]", login_path, count: 0
		assert_select "a[href=?]", logout_path
		assert_select "a[href=?]", user_path(@user)
		delete logout_path
		assert_not is_logged_in?
		assert_redirected_to root_url

		# 模拟2个窗口二次退出的情况
		delete logout_path
		follow_redirect!
		assert_select "a[href=?]", login_path
		assert_select "a[href=?]", logout_path, count: 0
		assert_select "a[href=?]", user_path(@user), count: 0
	end

	test 'login with remembering' do
		log_in_as(@user, remember_me: '1')
		# 不能使用 cookies[:remember_token]
		assert_not_empty cookies['remember_token']
	end

	test 'login without remembering' do
		# 登录设置 cookie
		log_in_as(@user, remember_me: '1')
		# 再次登录验证是否删除了 cookie
		log_in_as(@user, remember_me: '0')
		assert_empty cookies['remember_token']
	end
end
