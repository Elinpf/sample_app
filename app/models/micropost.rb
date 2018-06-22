class Micropost < ApplicationRecord
	# 与User关联
  belongs_to :user
	# LEARN -> 这个就是个Proc的匿名表达式
	# 查找方向是descending 下降, 
	default_scope -> { order(created_at: :desc) }
	validates :user_id, presence: true
	validates :content, presence: true, length: { maximum: 140 }
end
