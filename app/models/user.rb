class User < ApplicationRecord
    has_secure_password
    has_many :join_dbs, dependent: :destroy
    validates :email, uniqueness: { case_sensitive: false }
    validates :name, uniqueness: { case_sensitive: false }
    validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
end
