class AddStatusToJoinDb < ActiveRecord::Migration[5.0]
  def change
    add_column :join_dbs, :status, :integer, default: 1
  end
end
