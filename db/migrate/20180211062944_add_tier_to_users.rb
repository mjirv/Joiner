class AddTierToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :tier, :integer, default: 0
  end
end
