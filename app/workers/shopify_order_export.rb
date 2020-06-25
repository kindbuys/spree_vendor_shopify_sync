class ShopifyOrderExport
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_throttle({
    :concurrency => { :limit => 1, :key_suffix => -> (vendor_id, order_id) { [vendor_id, order_id] } }
  })

  def perform(vendor_id, order_id)
  	shopify_order_export = ShopifySync::Export::Orders.new(vendor_id, order_id)

    shopify_order_export.export_order

    shopify_order_export.clear_session
  end
end