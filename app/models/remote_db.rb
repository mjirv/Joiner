class RemoteDb < ApplicationRecord
  belongs_to :join_db
  enum db_type: %w(postgres mysql sql_server)
  validates :join_db_id, presence: true
  validates :db_type, presence: true
end
