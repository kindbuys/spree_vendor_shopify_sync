class Spree::ShopifiesController < Spree::StoreController

  def show
    redirect_to "https://#{params[:shop]}/admin/oauth/request_grant?client_id=#{ENV['SHOPIFY_API_KEY']}&scope=#{scopes}&redirect_uri=#{KINDBUYS_URL}/shopify/install&state=#{nonce}"
  end

  def install
  	binding.pry
  	if current_spree_user.present?
      redirect_to confirm_admin_shopify_sync_path(
      	hmac: params[:hmac], 
      	state: params[:state],
      	code: params[:code],
      	shop: params[:shop],
      	timestamp: params[:timestamp])
   	end

   	session["spree_user_return_to"] = confirm_admin_shopify_sync_path(
    	hmac: params[:hmac], 
    	state: params[:state],
    	code: params[:code],
    	shop: params[:shop],
    	timestamp: params[:timestamp]
    )
  end

  private

  def nonce
  	val = (0...8).map { (65 + rand(26)).chr }.join
  	session[:nonce] = val
  	val
  end

  def scopes
    'read_products,read_product_listings,read_orders,write_orders,read_draft_orders,write_draft_orders,read_inventory,write_inventory,read_locations'
  end
end
