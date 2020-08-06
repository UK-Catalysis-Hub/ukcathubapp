class User < ApplicationRecord
  has_secure_password

  #attr_accessible :email, :password, :password_confirmation

  validates_uniqueness_of :email
end
