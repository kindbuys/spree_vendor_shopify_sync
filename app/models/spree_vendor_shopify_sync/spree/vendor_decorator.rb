Spree::Vendor.class_eval do
  after_save :log_sync

  has_many :sync_logs, as: :syncable
  has_many :product_sync_logs, through: :products, source: :sync_logs

  def log_sync
    if saved_change_to_shopify_token? || saved_change_to_shopify_domain?
      sync_logs.create(
        provider: 'shopify', 
        status: 'OK',
        action: 'vendor_sync', options: {
          shopify_token: shopify_token, 
          shopify_shop: shopify_domain
        }
      )
    end
  end
end

 