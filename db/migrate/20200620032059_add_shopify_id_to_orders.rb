class AddShopifyIdToOrders < ActiveRecord::Migration[6.0]
  def change
  	add_column :spree_orders, :shopify_id, :string
  end
end
