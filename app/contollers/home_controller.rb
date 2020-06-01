# frozen_string_literal: true

class HomeController < AuthenticatedController
  def index
    @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    @webhooks = ShopifyAPI::Webhook.find(:all)
  end

  def import_products
    ShopifyProductSync.perform_async(vendor.id)
    render json: {status: :ok}
  end

  def sync_product
    ShopifyProductImport.perform_async(vendor.id, params[:id])
    render json: {status: :ok}
  end

  def vendor
  	Spree::Vendor.find_by(shopify_domain: @current_shopify_session.domain)
  end
end
