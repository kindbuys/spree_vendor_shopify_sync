Spree::Vendor.class_eval do
  include Encryptable
  attr_encrypted :shopify_token

  after_save :update_sync

  has_many :sync_logs

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
          syncable: self,
          options: {
            shopify_domain: shopify_domain
          }
        )
      else
        sync_logs.create(
          provider: 'shopify', 
          status: 'OK',
          action: 'vendor_disconnect', 
          syncable: self,
          options: {
            shopify_domain: shopify_domain
          }
        )
      end
    end
  end
end

 