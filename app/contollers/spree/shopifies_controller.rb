class Spree::ShopifiesController < Spree::StoreController

  def show
    redirect_to "https://#{params[:shop]}.myshopify.com/admin/oauth/request_grant?client_id=#{ENV['SHOPIFY_API_KEY']}&scope=#{scopes}&redirect_uri=#{confirm_admin_shopify_sync_path}&state=#{nonce}"
  end

  def nonce
  	val = (0...8).map { (65 + rand(26)).chr }.join
  	session[:nonce] = val
  	val
  end

  def scopes
    'read_products,read_product_listings,read_orders,write_orders,read_draft_orders,write_draft_orders,read_inventory,write_inventory,read_locations'
  end
end
