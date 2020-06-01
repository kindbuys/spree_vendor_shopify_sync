class ShopifySync::Import::Variants
	def initialize(product, shopify_product, option_values, vendor)
		@product = product
		@shopify_product = shopify_product
		@option_values = option_values
		@vendor = vendor
	end

	def sync_variants
		puts "SYNCING VARIANTS"
		@shopify_product.variants.each do |shopify_variant|
			if shopify_variant.option1 == 'Default Title'
				@product.master.update_attributes!(cost_price: shopify_variant.price, price: shopify_variant.price)
				next
			elsif shopify_variant.position == 1
				# if there are multiple variants, set default price to first one
				@product.master.update_attributes!(cost_price: shopify_variant.price, price: shopify_variant.price)
			end

			variant = get_variant(shopify_variant.id)

			#TODO iterate over shopify presentment prices to save spree::prices
			variant.assign_attributes(
				shopify_id: shopify_variant.id,
			  sku: shopify_variant.sku,
			  weight: shopify_variant.weight,
			  cost_price: shopify_variant.price,
			  currency: 'USD',
			  price: shopify_variant.price,
			  position: shopify_variant.position,
			  updated_at: shopify_variant.updated_at,
			  created_at: shopify_variant.created_at,
			  vendor_id: @vendor.id,
			)

			save_options(shopify_variant, variant)
			save_tax_category(shopify_variant, variant)
			save_inventory(shopify_variant, variant)
			variant.save!
		end
	end

	private

	def get_variant(shopify_variant_id)
		existing_variant = @product.variants_including_master.find_by(shopify_id: shopify_variant_id)
		existing_variant.present? ? existing_variant : @product.variants.new
	end

	def save_options(shopify_variant, variant)
		options = [shopify_variant.option1, shopify_variant.option2, shopify_variant.option3]

		options.each do |option|
			spree_option_value = @option_values.select { |hash| hash[:name] == option }.first

			if spree_option_value.present?
				variant.option_values << spree_option_value unless variant.option_values.include? spree_option_value
			end
		end

		# remove old option values
		variant.option_values.each do |variant_opt_value|
			unless @option_values.include? variant_opt_value
				variant_opt_value.destroy!
			end
		end

		variant.save!
	end

	def save_tax_category(shopify_variant, variant)
		if shopify_variant.taxable.present? && shopify_variant.try(:tax_code).present?
			tax_category = Spree::TaxCategory.find_or_initialize_by(tax_code: shopify_variant.tax_code)
			unless tax_category.persisted?
				tax_category.name = shopify_variant.tax_code
				#TODO find name with avalara tax api
				tax_category.save!
			end

			variant.tax_category = tax_category
			variant.save!
		end
	end

	def save_inventory(shopify_variant, variant)
	  if shopify_variant.inventory_item_id.present?
			shopify_inventory_item = ShopifyAPI::InventoryItem.find(shopify_variant.inventory_item_id)
			sleep(1)
			inventory_level = ShopifyAPI::InventoryLevel.find(:first, from: "#{ShopifyAPI::Base.prefix}inventory_levels.json?inventory_item_ids=#{shopify_variant.inventory_item_id}")
			sleep(0.5)

			if inventory_level.present?
				spree_location = ShopifySync::Import::StockLocations.new(inventory_level.location_id, @vendor).sync_stock_location
				save_stock_item = save_stock_item(spree_location, variant, inventory_level)
			end
		end
	end

	def save_stock_item(spree_location, variant, shopify_inventory)
		stock_item = Spree::StockItem.find_or_create_by!(
			stock_location: spree_location, 
			variant: variant
		)

		stock_item.updated_at = shopify_inventory.updated_at
		stock_item.count_on_hand = shopify_inventory.available
		stock_item.save!
	end
end
