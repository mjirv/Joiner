class RemoteDb < ApplicationRecord
  belongs_to :join_db
  enum db_type: %w(postgres mysql sql_server redshift csv)
  enum status: %w(disabled enabled provisioning)
  validates :join_db_id, presence: true
  validates :db_type, presence: true
  validates :database_name, presence: true, unless: -> record { record.csv? }
  validates :remote_user, presence: true, unless: -> record { record.csv? }
  validates :port, presence: true, if: -> record { not record.csv? }
  validates :host, presence: true, if: -> record { not record.csv? }
  validates :schema, presence: true, 
    if: -> record { record.postgres? or record.redshift? }

  def get_join_db_schema_name
    if self.postgres? or self.redshift?
      "#{self.database_name}_#{self.schema}"
    else
      "#{self.database_name}"
    end
  end

  def get_schema
    get_join_db_schema_name.downcase
  end

  def get_tables(password)
    # Return an array of table names
    JoindbApi.get_tables(self, password)
  end

  def disable
    self.status = RemoteDb.statuses[:disabled]
    self.save
  end

end
