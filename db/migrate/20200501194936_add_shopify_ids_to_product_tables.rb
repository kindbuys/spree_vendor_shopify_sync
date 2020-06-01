class AddShopifyIdsToProductTables < ActiveRecord::Migration
  def change
  	add_column :spree_products, :shopify_id, :string
  	add_column :spree_variants, :shopify_id, :string
		add_column :spree_option_types, :shopify_id, :string
		add_column :spree_stock_locations, :shopify_id, :string
  end
end
