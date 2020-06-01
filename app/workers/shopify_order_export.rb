class ShopifyOrderExport
  include Sidekiq::Worker

  def perform(vendor_id, order_id)
  	shopify_order_export = ShopifySync::Export::Orders.new(vendor_id, order_id)

    shopify_order_export.export_order

    shopify_order_export.clear_session
  end
end