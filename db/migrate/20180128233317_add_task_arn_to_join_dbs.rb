class AddTaskArnToJoinDbs < ActiveRecord::Migration[5.0]
  def change
    add_column :join_dbs, :task_arn, :uuid
  end
end
