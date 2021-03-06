class User < ApplicationRecord
	attr_accessor :remember_token, :activation_token, :reset_token
	# 与 Microposts 关联, 注意是复数
	# :microposts 是方法名, 他的class,Rails 自动识别成为Micropost
	# 与 destroy 联动, 删除了user同时删除 microposts
	has_many :microposts, dependent: :destroy
	# 使用的:active_relationship是方法名, 但是实际的class是Relationship
	#  外键 "follower_id", User表中follower_id, 指的就是relationship_id
	#			Rails默认使用的是<class.downcase>_id, 
	#			Rails 是不会自己创建外键字段, 需要在迁移中手动创建
	has_many :active_relationships, class_name: "Relationship",	
							foreign_key: "follower_id",
							dependent: :destroy
	# through: 多对多模型
	has_many :following, through: :active_relationships, source: :followed

	# passive_relationships
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :followers, through: :passive_relationships, source: :follower
	# 在保存之前做的事
	before_save :downcase_email
	before_create :create_activation_digest

	# name， 不能为空， 最大长度为50
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	# email，不能为空，最大长度255, 格式要求， 数据库中唯一并且大小写不敏感
	validates :email, presence: true, length: { maximum: 255 },
						format: { with: VALID_EMAIL_REGEX },
						uniqueness: { case_sensitive: false }

	# 启用安全的password认证， Gemfile中添加了 'bcrypt'
	has_secure_password
	# password 要求
	# 允许为空是因为 has_secure_password 会捕获空密码
	# 当是新注册的时候空密码会失败，而PATCH更新的时候会绕过密码修改
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	# 没有特殊要求的字段是可以不用单独添加的

	# 返回一个加密的Hash值
	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	# 生成一个长度为22的随机码作为长期登录token
	def User.new_token
		SecureRandom.urlsafe_base64
	end

	# 更新remember_digest字段
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	# 忘记一个remember_token
	def forget
		update_attribute(:remember_digest, nil)
	end

	# 验证是否为合法cookies
	# 同时验证　remember 和 activation
	def authenticated?(attribute, token)
		# 这里的remeber_digest 其实是 self.remember_digest
		# User 类在db:migrate后就会将其默认附加到 attr_accessor :remember_digest
		digest = self.send("#{attribute}_digest")
		return false if digest.nil?
		# 两个值进行比较
		BCrypt::Password.new(digest).is_password?(token)
	end

	# 激活账户
	# 这里是没有使用user.update_attribute
	# 是因为本身就是user的实例
	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	# 发送激活邮件
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	# 设置password_reset_digest
	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end

	# 发送Email
	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	# 设置超时时间
	def password_reset_expired?
		self.reset_sent_at < 2.hours.ago
	end

	def feed
		# 这里用的是SQL的语句
		Micropost.where("user_id = ?", id)
	end

	# 加入关注的用户
	def follow(other_user)
		following << other_user
	end

	# 删除关注的用户
	def unfollow(other_user)
		following.delete(other_user)
	end

	# 返回是否存在关注的用户
	def following?(other_user)
		following.include?(other_user)
	end

	# 返回一个User的状态feed
	# following_ids 是自带的命令
	# 使用了内嵌式的SQL语句代码
	def feed
		#Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
		following_ids = "SELECT followed_id FROM relationships " + 
					"WHERE follower_id = :user_id"
		Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id",
					user_id: id)
	end

private
	
	def downcase_email
		self.email = email.downcase
	end

	# 在创建用户之前向建一个digest用于验证
	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(activation_token)
	end
end
