class AddFieldsToLogs < ActiveRecord::Migration
  def change
  	add_column :sync_logs, :status, :string
  	add_column :sync_logs, :message, :string
  end
end
