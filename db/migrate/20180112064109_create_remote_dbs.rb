class CreateRemoteDbs < ActiveRecord::Migration[5.0]
  def change
    create_table :remote_dbs do |t|
      t.string :name
      t.string :schema
      t.string :host
      t.integer :port
      t.string :remote_user
      t.integer :db_type
      t.references :join_db, foreign_key: true
      t.string :database_name

      t.timestamps
    end
  end
end
