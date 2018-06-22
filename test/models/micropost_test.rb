require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
	
=begin
	# LEARN	User 和 Micropost 的对应关系和方法
	micropost.user 	Returns the User object associated with the micropost
	user.microposts 	Returns a collection of the user’s microposts
	user.microposts.create(arg) 	Creates a micropost associated with user
	user.microposts.create!(arg) 	Creates a micropost associated with user (exception on failure)
	user.microposts.build(arg) 	Returns a new Micropost object associated with user
	user.microposts.find_by(id: 1) 	Finds the micropost with id 1 and user_id equal to user.id
=end
	def setup
		@user = users(:michael)

		@micropost = @user.microposts.build(content: "Lorem ipsum")
	end

	test "should be valid" do
		assert @micropost.valid?
	end

	test 'user id should be present' do
		@micropost.user_id = nil
		assert_not @micropost.valid?
	end

  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

	test 'order should be most recent first' do
		assert_equal microposts(:most_recent), Micropost.first
	end
end
