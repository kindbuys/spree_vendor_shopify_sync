class AddEncryptedShopifyApiTokenToVendors < ActiveRecord::Migration
  def change
  	add_column :spree_vendors, :shopify_token, :string
  	add_column :spree_vendors, :shopify_domain, :string
  end
end
