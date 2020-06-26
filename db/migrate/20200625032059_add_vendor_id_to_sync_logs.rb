class AddVendorIdToSyncLogs < ActiveRecord::Migration[6.0]
  def change
  	add_column :sync_logs, :vendor_id, :integer
  end
end
