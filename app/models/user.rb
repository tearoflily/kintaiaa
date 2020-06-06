class User < ApplicationRecord

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, uniqueness: true
  
  has_secure_password
  validates :password, presence: true, allow_nil: true

  
end
