class CreateMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :mappings do |t|
      t.string :name
      t.integer :join_db_id
      t.integer :user_id
      t.integer :remote_db_one
      t.integer :remote_db_two
      t.string :table_one
      t.string :table_two
      t.string :column_one
      t.string :column_two

      t.timestamps
    end
  end
end
