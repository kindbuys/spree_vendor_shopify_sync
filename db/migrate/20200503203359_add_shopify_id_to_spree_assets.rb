class AddShopifyIdToSpreeAssets < ActiveRecord::Migration
  def change
  	add_column :spree_assets, :shopify_id, :string
  end
end
