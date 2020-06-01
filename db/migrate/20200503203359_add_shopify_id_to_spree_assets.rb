class AddShopifyIdToSpreeAssets < ActiveRecord::Migration[6.0]
  def change
  	add_column :spree_assets, :shopify_id, :string
  end
end
