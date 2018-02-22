class RemoteDb < ApplicationRecord
  belongs_to :join_db
  enum db_type: %w(postgres mysql sql_server redshift csv)
  validates :join_db_id, presence: true
  validates :db_type, presence: true
  validates :database_name, presence: true, unless: -> record { record.csv? }
  validates :remote_user, presence: true, unless: -> record { record.csv? }
  validates :port, presence: true, if: -> record { not record.csv? }
  validates :host, presence: true, if: -> record { not record.csv? }
  validates :schema, presence: true, 
    if: -> record { record.postgres? or record.redshift? }

end
