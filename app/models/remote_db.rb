class RemoteDb < ApplicationRecord
  belongs_to :join_db
  enum db_type: %w(postgres mysql sql_server)
  validates :join_db_id, presence: true
  validates :db_type, presence: true
  validates :database_name, presence: true
  validates :remote_user, presence: true
  validates :port, presence: true
  validates :host, presence: true
  validates :schema, presence: true, if: :postgres? 
end
