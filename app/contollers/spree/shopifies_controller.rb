require 'shopify_api'

class Spree::ShopifiesController < Spree::StoreController
  def show
    redirect_to "https://#{params[:shop]}/admin/oauth/authorize?client_id=#{ENV['SHOPIFY_API_KEY']}&scope=#{scopes}&redirect_uri=#{KINDBUYS_URL}/shopify/install&state=#{nonce}"
  end

  def request_access
    ShopifyAPI::Session.setup(api_key: ENV['SHOPIFY_API_KEY'], secret: ENV['SHOPIFY_SECRET_API_KEY'])
    shopify_session = ShopifyAPI::Session.new(domain: params[:shop], api_version: ENV['SHOPIFY_API_VERSION'], token: nil)
    permission_url = shopify_session.create_permission_url(scope_list, "#{KINDBUYS_URL}/shopify/install", { state: nonce })
    redirect_to permission_url
  end

  def confirm
    if validate_request
      response = fetch_shopify_code

      if response.code != '200'
        flash[:error] = response.message
      else
        flash[:success] = "Success! #{params[:shop]} is now linked to KindBuys"

        save_access_token(response)
      end
    else
      flash[:error] = "Invalid Request"
    end

    redirect_to 'localhost:3000'
  end

  def install
    #response.headers["X-FRAME-OPTIONS"] = "ALLOW-ALL"

  	#if current_spree_user.present?
    #  redirect_to confirm_admin_shopify_sync_path(
    #  	hmac: params[:hmac], 
    #  	state: params[:state],
    #  	code: params[:code],
    #  	shop: params[:shop],
    #  	timestamp: params[:timestamp])
   	#end

   	#session["spree_user_return_to"] = confirm_admin_shopify_sync_path(
   # 	hmac: params[:hmac], 
   # 	state: params[:state],
   # 	code: params[:code],
   # 	shop: params[:shop],
   # 	timestamp: params[:timestamp]
   # )
   if validate_request
      response = fetch_shopify_code

      if response.code != '200'
        flash[:error] = response.message
      else
        flash[:success] = "Success! #{params[:shop]} is now linked to KindBuys"

        save_access_token(response)
      end
    else
      flash[:error] = "Invalid Request"
    end

    redirect_to "#{params[:shop]}/admin/apps/kindbuys_sales_channel"
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
    rand(10 ** 30).to_s.rjust(30,'0')
  end

  def scopes
    'read_product_listings,write_checkouts'
  end

  def validate_request
    validate_state && validate_hmac && validate_hostname
  end

  def validate_state
    #Ensure the provided state is the same one that your application 
    #provided to Shopify in the previous step.

    params[:state] == @vendor.try(:nonce) || params[:state] == session[:nonce]
  end

  def validate_hmac
    #Ensure the provided hmac is valid. The hmac is signed by Shopify, 
    #as explained below in the Verification section.

    digest = OpenSSL::Digest.new('sha256')
    secret = ENV['SHOPIFY_SECRET_API_KEY']

    digest = OpenSSL::HMAC.hexdigest(digest, secret, hmac_param_string)
    ActiveSupport::SecurityUtils.secure_compare(digest, params[:hmac])
  end

  def validate_hostname
    #Ensure the provided hostname parameter is a valid hostname, ends with myshopify.com, 
    #and does not contain characters other than letters (a-z), numbers (0-9), dots, and hyphens.

    !!(/(https|http)\:\/\/[a-zA-Z0-9][a-zA-Z0-9\-]*\.myshopify\.com[\/]?/ =~ params[:shop]) || 
    !!(/[a-zA-Z0-9][a-zA-Z0-9\-]*\.myshopify\.com[\/]?/ =~ params[:shop])
  end

  def hmac_param_string
    message = ''

    hmac_param_map.sort.to_h.each_with_index do |(k,v), i|
      message += "#{k}=#{v}"
      message += '&' unless i == 3
    end

    message
  end

  def hmac_param_map
    param_map = {}
    params.each do |k,v| 
      param_map[k] = v if ['code', 'shop', 'state', 'timestamp'].include? k
    end

    param_map
  end

  def save_access_token(response)
    access_token = JSON.parse(response.body)['access_token']
    vendor = Spree::Vendor.friendly.find_by(id: session[:vendor]) || current_spree_user.vendors.first
    
    if vendor.present? && access_token.present?
      vendor.shopify_token = access_token
      vendor.shopify_domain = params[:shop]
      vendor.save
    end
  end

  def fetch_shopify_code
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(post_params)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    http.request(request)
  end

  def authorize
    authorize! :manage, :vendor_settings
  end

  def verify_webhook
    calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', ENV['SHOPIFY_SECRET_API_KEY'], request.body.read))
    ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"])
  end

  def url
    "https://#{params[:shop]}/admin/oauth/access_token"
  end

  def post_params
    {
      client_id: ENV['SHOPIFY_API_KEY'],
      client_secret: ENV['SHOPIFY_SECRET_API_KEY'],
      code: params[:code]
    }
  end

  def scope_list
    ['read_product_listings,write_checkouts']
  end
end
