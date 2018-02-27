class AddStatusToRemoteDb < ActiveRecord::Migration[5.0]
  def change
    add_column :remote_dbs, :status, :integer, default: 1
  end
end
