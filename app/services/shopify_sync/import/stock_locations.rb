class ShopifySync::Import::StockLocations
	def initialize(shopify_location_id, vendor)
		@vendor = vendor
		@shopify_location = ShopifyAPI::Location.find(shopify_location_id)
	end

	def sync_stock_location
		sleep(0.5)
		spree_stock_location = get_stock_location
		spree_country = get_country
		spree_state = get_state(spree_country)

		spree_stock_location.update_attributes!(
			shopify_id: @shopify_location_id,
			name: @shopify_location.name,
			created_at: @shopify_location.created_at,
			updated_at: @shopify_location.updated_at,
			address1: @shopify_location.address1, 
			address2: @shopify_location.address2, 
			city: @shopify_location.city, 
			state: spree_state,
			country: spree_country,
			zipcode: @shopify_location.zip,
			phone: @shopify_location.phone,
			active: @shopify_location.active,
			admin_name: @shopify_location.name,
			propagate_all_variants: true
		)

		spree_stock_location
	end

	private

	def get_stock_location
		existing_stock_location = Spree::StockLocation.find_by(name: @shopify_location.name, vendor_id: @vendor.id)
		existing_stock_location.present? ? existing_stock_location : @vendor.stock_locations.new(name: @shopify_location.name)
	end

	def get_country
		sleep(0.5)
		Spree::Country.find_or_create_by(iso3: @shopify_location.country_code, name: @shopify_location.country_name)
	end
	
	def get_state(country)
		sleep(0.5)
		Spree::State.find_or_create_by(name: @shopify_location.province, abbr: @shopify_location.province_code, country_id: country.id)
	end
end
