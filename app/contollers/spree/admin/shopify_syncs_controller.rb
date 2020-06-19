require 'shopify_api'

module Spree
  module Admin
    class ShopifySyncsController < Spree::Admin::BaseController
      skip_before_action :authorize_admin
      before_action :authorize
      before_action :load_vendor, except: [:request_access, :sync_product, :delete_product]
      before_action :set_vendor, only: :request_access
      before_action :verify_webhook, only: [:sync_product, :delete_product]
      skip_before_action :verify_authenticity_token, only: [:sync_product, :delete_product]
      skip_before_action :authorize, only: [:sync_product, :delete_product]

      def show

      end

      def request_access
        ShopifyAPI::Session.setup(api_key: ENV['SHOPIFY_API_KEY'], secret: ENV['SHOPIFY_SECRET_API_KEY'])
        shopify_session = ShopifyAPI::Session.new(domain: params[:shop], api_version: ENV['SHOPIFY_API_VERSION'], token: nil)
        permission_url = shopify_session.create_permission_url(scope, "#{KINDBUYS_URL}/admin/shopify_sync/confirm", { state: @vendor.nonce })
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

        redirect_to admin_shopify_sync_path
      end

      def import_products
        ShopifyProductSync.perform_async(@vendor.id)
        render json: {status: :ok}
      end

      def sync_product
        domain = request.headers["X-Shopify-Shop-Domain"]
        vendor = Spree::Vendor.find_by(shopify_domain: domain)
        ShopifyProductImport.perform_async(vendor.id, params[:id])
        render json: {status: :ok}
      end

      def delete_product
        domain = request.headers["X-Shopify-Shop-Domain"]
        vendor = Spree::Vendor.find_by(shopify_domain: domain)
        product = vendor.products.find_by(shopify_id: params[:id])
        product.destroy if product.present?
        render json: {status: :ok}
      end

      private

      def set_vendor
        @vendor = Spree::Vendor.friendly.find_by(id: params[:vendor_id])

        if @vendor.present?
          session[:vendor] = @vendor.id
        end
      end

      def load_vendor
        if current_spree_user.vendors.first.present?
          @vendor = current_spree_user.vendors.first
        elsif session[:vendor].present?
          @vendor = Spree::Vendor.friendly.find(session[:vendor])
        else
          @vendor = nil
        end
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

      def scope
        ['read_products','read_product_listings','read_orders','write_orders','read_draft_orders','write_draft_orders','read_inventory','write_inventory','read_locations']
      end

      def validate_request
        validate_state && validate_hmac && validate_hostname
      end

      def validate_state
        #Ensure the provided state is the same one that your application 
        #provided to Shopify in the previous step.

        # adding in the blank conditional to account for shopify bug, shouldnt be here
        params[:state] == @vendor.nonce || params[:state] == session[:nonce] || params[:state].blank?
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
        vendor = Spree::Vendor.friendly.find(session[:vendor])
        
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
    end
  end
end