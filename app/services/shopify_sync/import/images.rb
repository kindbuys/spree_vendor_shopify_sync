class ShopifySync::Import::Images
	def initialize(spree_product, shopify_product)
		@spree_product = spree_product
		@shopify_product = shopify_product
	end

	def sync_images
		@spree_product.images.destroy_all

		@shopify_product.images.each do |shopify_image|
			if shopify_image.variant_ids.present?
				shopify_image.variant_ids.each do |variant_id|
					p "SAVING VARIANT IMAGE #{variant_id}"
					save_image(variant_id, shopify_image)
				end
			else
				p "SAVING MASTER IMAGE #{@spree_product.master.shopify_id}"
				save_image(@spree_product.master.shopify_id, shopify_image)
			end
		end
	end

	def save_image(shopify_variant_id, shopify_image)
		file = open(shopify_image.src)
		variant = Spree::Variant.find_by(shopify_id: shopify_variant_id)
		sleep(0.5)

		if variant.blank?
			p "VARIANT MISSING"
		end
		image = Spree::Image.new.attachment.attach(io: file, filename: shopify_image.id)
		image.record.attachment_file_name = shopify_image.id
		image.record.viewable = variant
		image.record.save!
		
		sleep(0.5)
	end
end