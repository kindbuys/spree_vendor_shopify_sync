Spree::Variant.class_eval do
	def shopify_title
  	option_values.order(:position).map(&:name).join(' / ')
  end
end