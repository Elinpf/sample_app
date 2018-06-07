class User < ApplicationRecord
	attr_accessor :remember_token
	# 在保存之前做的事
	before_save { self.email = email.downcase }

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
	validates :password, presence: true, length: { minimum: 6 }

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
	def authenticated?(remember_token)
		# 这里的remeber_digest 其实是 self.remember_digest
		# User 类在db:migrate后就会将其默认附加到 attr_accessor :remember_digest
		return false if remember_digest.nil?
		BCrypt::Password.new(remember_digest) == remember_token
	end
end
