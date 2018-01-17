class User < ApplicationRecord
    has_secure_password
    has_many :join_dbs, dependent: :destroy
    validates :email, uniqueness: true
end
