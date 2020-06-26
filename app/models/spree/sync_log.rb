module Spree
  class SyncLog < Spree::Base
	  self.table_name = 'sync_logs'
	  
		belongs_to :vendor

		def descriptor
			if syncable_type == 'Spree::Vendor'
				options['shopify_domain']
			elsif syncable_type == 'Spree::Product'
				options['title']
			elsif syncable_type == 'Spree::Order'
				syncable.try(:number)
			end
		end
	end
end