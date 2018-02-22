class AddFilepathToRemoteDbs < ActiveRecord::Migration[5.0]
  def change
    add_column :remote_dbs, :filepath, :string
  end
end
