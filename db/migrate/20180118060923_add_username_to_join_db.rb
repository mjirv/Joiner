class AddUsernameToJoinDb < ActiveRecord::Migration[5.0]
  def change
    add_column :join_dbs, :username, :string
  end
end
