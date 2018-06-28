class RelationshipsController < ApplicationController
	before_action :logged_in_user

	def create
		@user = User.find(params[:followed_id])
		current_user.follow(@user)
		# LEARN 使用Ajax技术
		respond_to do |f|
			f.html  { redirect_to @user }
			f.js
		end
	end

	def destroy
		@user = Relationship.find(params[:id]).followed
		current_user.unfollow(@user)
		respond_to do |f|
			f.html { redirect_to @user }
			f.js
		end
	end
end
