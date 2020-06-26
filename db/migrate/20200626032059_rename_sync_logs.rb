class RenameSyncLogs < ActiveRecord::Migration[6.0]
  def change
    rename_table :sync_logs, :spree_sync_logs
  end 
end
