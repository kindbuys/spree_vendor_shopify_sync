class AddVendorIdToSyncLogs < ActiveRecord::Migration[6.0]
  def change
  	add_column :sunc, :shopify_id, :string
  end
end
