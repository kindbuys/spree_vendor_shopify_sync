class ShopifySync::Import::Products
	def initialize(vendor_id, shopify_product_id = nil)
		@vendor_id = vendor_id
		@shopify_product_id = shopify_product_id
	end

	def sync_product
		ActiveRecord::Base.transaction do
			shopify_product = ShopifyAPI::Product.find(@shopify_product_id)
			spree_product = get_product
			puts "SYNCING SHOPIFY PRODUCT #{@shopify_product_id}"

			spree_product.update!(
				name: shopify_product.title,
				description: shopify_product.body_html,
				available_on: shopify_product.published_at,
				slug: shopify_product.handle,
				meta_keywords: shopify_product.tags,
				created_at: shopify_product.created_at,
				updated_at: shopify_product.updated_at,
				shopify_id: shopify_product.id,
				shipping_category: Spree::ShippingCategory.default,
				price: 0,
				discontinue_on: nil,
				state: 'pending'
			)

			spree_product.master.update_attributes!(shopify_id: spree_product.shopify_id)

			ShopifySync::Import::Taxons.new(shopify_product.product_type, spree_product).save_taxon
			binding.pry
			option_values = ShopifySync::Import::Options.new(shopify_product, vendor).sync_options
			ShopifySync::Import::Variants.new(spree_product, shopify_product, option_values, vendor).sync_variants
			ShopifySync::Import::Images.new(spree_product, shopify_product).sync_images

			spree_product.sync_logs.create(
				provider: 'shopify', 
				action: 'product_import', 
				options: JSON.parse(shopify_product.to_json),
				status: 'OK'
			)
		end
	rescue => e
		Spree::SyncLog.create(
			provider: 'shopify', 
			action: 'product_import', 
			message: e,
			status: 'FAIL'
		)
	end

	def remove_old_products(shopify_product_ids)
		current_spree_products = vendor.products
		removed_products = 0

		current_spree_products.each do |spree_product|
			unless shopify_product_ids.include? spree_product.shopify_id
				removed_products += 1
				spree_product.deleted_at = Time.now
			end
		end

		puts "REMOVED #{removed_products} PRODUCTS"
	end

	private

	def get_product
		existing_product = vendor.products.find_by(shopify_id: @shopify_product_id)
		existing_product.present? ? existing_product : vendor.products.new
	end

	def vendor
   Spree::Vendor.friendly.find(@vendor_id)
	end
end
