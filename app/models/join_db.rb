class JoinDb < ApplicationRecord
    belongs_to :user
    has_many :remote_dbs, dependent: :destroy
    validates :user_id, presence: true
end
