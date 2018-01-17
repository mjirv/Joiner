class RemoteDb < ApplicationRecord
  belongs_to :join_db
  validates :join_db_id, presence: true
  validates :db_type, inclusion: { in: [0, 1] }
end
