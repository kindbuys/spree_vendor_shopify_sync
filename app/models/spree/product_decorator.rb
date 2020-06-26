Spree::Product.class_eval do
  has_many :sync_logs, as: :syncable
end