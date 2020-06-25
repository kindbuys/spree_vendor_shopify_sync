Spree::Vendor.class_eval do
  include Encryptable
  attr_encrypted :shopify_token

  after_save :update_sync

  has_many :sync_logs, as: :syncable
  has_many :product_sync_logs, through: :products, source: :sync_logs
  has_many :order_sync_logs, through: :orders, source: :sync_logs

  def nonce
    "#{name}-#{id}-#{created_at}"
  end

  def update_sync
    if saved_change_to_encrypted_shopify_token? || saved_change_to_shopify_domain?
      if encrypted_shopify_token.present? && shopify_domain.present?
        ShopifyWebhookSubscribe.perform_async(id)

        sync_logs.create(
          provider: 'shopify', 
          status: 'OK',
          action: 'vendor_sync', 
          options: {
            shopify_domain: shopify_domain
          }
        )
      else
        sync_logs.create(
          provider: 'shopify', 
          status: 'OK',
          action: 'vendor_disconnect', 
          options: {
            shopify_domain: shopify_domain
          }
        )
      end
    end
  end
end

 