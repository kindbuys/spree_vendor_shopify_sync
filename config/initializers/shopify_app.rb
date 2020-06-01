ShopifyApp.configure do |config|
  config.application_name = "Spree Vendor Shopify Sync"
  config.api_key = ENV['SHOPIFY_API_KEY']
  config.secret = ENV['SHOPIFY_API_SECRET']
  config.scope = "read_products, read_product_listings, read_orders, write_orders, read_draft_orders, write_draft_orders, read_inventory, write_inventory, read_locations"
  config.embedded_app = false
  config.after_authenticate_job = false
  config.api_version = "2020-04"
  config.shop_session_repository = 'Spree::Vendor'
  config.webhooks = [
    { topic: 'products/create', address: "#{KINDBUYS_URL}/admin/shopify_sync/sync_product" },
    { topic: 'products/update', address: "#{KINDBUYS_URL}/admin/shopify_sync/sync_product" },
    { topic: 'products/create', address: "#{KINDBUYS_URL}/admin/shopify_sync/delete_product" }
  ]
end

# ShopifyApp::Utils.fetch_known_api_versions                        # Uncomment to fetch known api versions from shopify servers on boot
# ShopifyAPI::ApiVersion.version_lookup_mode = :raise_on_unknown    # Uncomment to raise an error if attempting to use an api version that was not previously known
