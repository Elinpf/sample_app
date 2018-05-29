require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

	test "layout links" do
		get root_path
		# 确认返回的模板
		assert_template 'static_pages/home'
		# 确认有几个对应的链接
		assert_select "a[href=?]", root_path, count: 2
		assert_select "a[href=?]", help_path
		assert_select "a[href=?]", about_path
		assert_select "a[href=?]", contact_path
	end
end
