class RemoteDb < ApplicationRecord
  belongs_to :join_db
  enum db_type: %w(postgres mysql)
  validates :join_db_id, presence: true
end
