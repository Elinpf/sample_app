class User < ApplicationRecord
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
end
