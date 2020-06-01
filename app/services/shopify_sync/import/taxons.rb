class ShopifySync::Import::Taxons
	def initialize(shopify_category, product)
		@shopify_category = shopify_category
		@product = product
	end

	def save_taxon
		# not deleting extra taxons...
		puts "CREATING TAXON #{@shopify_category}"

		taxon = Spree::Taxon.find_or_create_by(name: @shopify_category)
		Spree::Classification.find_or_create_by(taxon: taxon, product: @product)
		binding.pry
	end
end