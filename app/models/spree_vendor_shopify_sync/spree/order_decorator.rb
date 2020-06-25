Spree::Order.class_eval do
	after_save :sync_shopify_order
	has_many :sync_logs, as: :syncable

	def weight
		variants.map(&:weight).sum
	end

	def sync_shopify_order
		if state == 'complete'
			binding.pry
			# this runs multiple times ... prevent some
			vendors.each do |vendor|
				ShopifyOrderExport.perform_async(vendor.id, id)
			end
		end
	end

	def vendor_tax_total(vendor)
		line_items.for_vendor(vendor).sum(:included_tax_total) + line_items.for_vendor(vendor).sum(:additional_tax_total)
	end

	def vendor_promo_total(vendor)
		line_items.for_vendor(vendor).sum(:promo_total)
	end

	def vendors
		vendor_arr = []

		line_items.each do |line_item|
			if line_item.product.vendor.try(:shopify_token).present?
				vendor_arr << line_item.product.vendor
			end
		end

		vendor_arr.uniq
	end
end
