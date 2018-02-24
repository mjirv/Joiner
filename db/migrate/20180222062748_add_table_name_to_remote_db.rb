class AddTableNameToRemoteDb < ActiveRecord::Migration[5.0]
  def change
    add_column :remote_dbs, :table_name, :string
  end
end
