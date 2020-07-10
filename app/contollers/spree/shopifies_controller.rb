class Spree::ShopifiesController < Spree::StoreController

  def show
    redirect_to "https://#{params[:shop]}/admin/oauth/authorize?client_id=#{ENV['SHOPIFY_API_KEY']}&scope=#{scopes}&redirect_uri=#{KINDBUYS_URL}/shopify/install&state=#{nonce}"
  end

  def install
    response.headers["X-FRAME-OPTIONS"] = "ALLOW-ALL"

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

  # Don't think any of the redactions/requests apply since we are not
  # saving data from Shopify.
  def redact
		#vendor = Spree::Vendor.find_by(shopify_domain: params[:shopify_domain])
		#order_ids_to_redact = params[:orders_to_redact]

		#vendor.orders.where(shopify_id: order_ids_to_redact).update_all(shopify_id: nil)
    render json: {status: :ok}
  end

  private

  def nonce
  	val = (0...8).map { (65 + rand(26)).chr }.join
  	session[:nonce] = val
  	val
  end

  def scopes
    'read_product_listings,write_checkouts'
  end
end
