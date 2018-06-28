class Micropost < ApplicationRecord
  # 与User关联
  belongs_to :user
	# LEARN -> 这个就是个Proc的匿名表达式
	# 查找方向是descending 下降, 
	default_scope -> { order(created_at: :desc) }
	# 其实相当于是挂在,定义 :picture 是 PictureUploader这个类的表示
	mount_uploader :picture, PictureUploader
	validates :user_id, presence: true
	validates :content, presence: true, length: { maximum: 140 }
	# 验证照片的大小
	validate :picture_size

private
	
	def picture_size
		if picture.size > 5.megabytes
			errors.add(:picture, "should be less than 5MB")
		end
	end
end
