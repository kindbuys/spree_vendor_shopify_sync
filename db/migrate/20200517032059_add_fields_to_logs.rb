class AddFieldsToLogs < ActiveRecord::Migration[6.0]
  def change
  	add_column :sync_logs, :status, :string
  	add_column :sync_logs, :message, :string
  end
end
