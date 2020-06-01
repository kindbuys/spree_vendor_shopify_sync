class AddEncryptedShopifyApiTokenToVendors < ActiveRecord::Migration[6.0]
  def change
  	add_column :spree_vendors, :encrypted_shopify_token, :string
  	add_column :spree_vendors, :shopify_domain, :string
  end
end
