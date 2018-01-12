class CreateJoinDbs < ActiveRecord::Migration[5.0]
  def change
    create_table :join_dbs do |t|
      t.string :name
      t.string :host
      t.integer :port
      t.references :user , foreign_key: true

      t.timestamps
    end
  end
end
