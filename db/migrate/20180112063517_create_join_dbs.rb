class CreateJoinDbs < ActiveRecord::Migration[5.0]
  def change
    create_table :join_dbs do |t|
      t.string :name
      t.string :host
      t.int :port
      t.int :user_id

      t.timestamps
    end
  end
end
