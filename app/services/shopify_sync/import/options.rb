class ShopifySync::Import::Options
	def initialize(shopify_product, vendor)
		@vendor = vendor
		@shopify_product = shopify_product
	end

	def sync_options
		option_values = []
		binding.pry
		@shopify_product.options.each do |shopify_option|
			sleep(0.5)
			puts "SYNCING OPTION TYPE #{shopify_option.name} #{@vendor.name}"
			option_type = get_option_type(shopify_option.name)

			option_type.update_attributes!(
				shopify_id: shopify_option.id,
				presentation: shopify_option.name,
				position: shopify_option.position, 
			)
			
			shopify_option.values.each_with_index do |shopify_value, index|
				option_value = get_option_value(option_type, shopify_value)

				option_value.update_attributes!(
					position: index,
				  name: shopify_value,
				  presentation: shopify_value,
				  created_at: option_type.created_at,
				  updated_at: option_type.updated_at
				)

				option_values << option_value
			end
		end

		option_values
	end

	private

	def get_option_type(name)
		existing_option_type = Spree::OptionType.find_by(name: name, vendor_id: @vendor.id)
		existing_option_type.present? ? existing_option_type : @vendor.option_types.new(name: name)
	end

	def get_option_value(option_type, shopify_option_name)
		existing_option = option_type.option_values.find_by(name: shopify_option_name)
		existing_option.present? ? existing_option : option_type.option_values.new
	end
end
