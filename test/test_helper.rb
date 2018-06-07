ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

	# 返回测试用户是否登录
	def is_logged_in?
		!session[:user_id].nil?
	end

	def log_in_as(user)
		session[:user_id] = user.id
	end
end

# NOTE 不是很清楚ActionDispatch这个类
class ActionDispatch::IntegrationTest
	
	# 用的是和上面一样的方法名
	def log_in_as(user, password: 'password', remember_me: '1')
		post login_path, params: { session: { email: user.email,
						password: password, remember_me: remember_me } }
	end
end
