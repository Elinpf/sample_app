require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
	# 因为使用到了app/helpers/application_helper.rb
	include ApplicationHelper

	def setup
		@user = users(:michael)
	end

	test 'profile display' do
		get user_path(@user)
		assert_template 'users/show'
		assert_select 'title', full_title(@user.name)
		assert_select 'h1', text: @user.name
		# 嵌套在h1里面的img包含class='gravatar'
		assert_select 'h1>img.gravatar'
		# response 是回复的整个html
		assert_match @user.microposts.count.to_s, response.body
		assert_select 'div.pagination'
		@user.microposts.paginate(page: 1).each do |micropost|
			assert_match micropost.content, response.body
		end
	end
end
