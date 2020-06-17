class ShopifySync::Export::Orders < ShopifySync::Base

	def initialize(vendor_id, order_id)
		super(vendor_id)
		@order_id = order_id
	end

	def export_order
		ActiveRecord::Base.transaction do
			shopify_order = ShopifyAPI::Order.new(
				email: order.email,
				created_at: order.created_at,
				updated_at: order.updated_at,
				test: Rails.env != 'production',
				total_price: order.vendor_total(vendor),
				subtotal_price: order.vendor_subtotal(vendor),
				total_weight: order.weight,
				total_tax: order.vendor_tax_total(vendor),
				taxes_included: true,
				currency: order.currency,
				financial_status: 'authorized',
				total_discounts: order.vendor_promo_total(vendor),
				total_line_items_price: order.line_items.for_vendor(vendor).sum(&:total),
				cancelled_at: order.canceled_at,
				fulfillment_status: nil,
				tags: 'kind-buys'
			)

			shopify_order.line_items = line_items
			shopify_order.billing_address = address(:billing_address)
			shopify_order.shipping_address = address(:shipping_address)
			shopify_order.shipping_lines = shipping

			if shopify_order.save
				order.update_attributes(shopify_id: shopify_order.id)
			else
				log_order(shopify_order.errors.details)
			end
		end
	rescue => e
		log_order(e)
	end

	private

	def line_items
		order.line_items.for_vendor(vendor).map do |line_item|
			{
				variant_id: line_item.variant.shopify_id,
				title: line_item.product.name,
				quantity: line_item.quantity,
				sku: line_item.variant.sku,
				variant_title: line_item.variant.shopify_title,
				product_id: line_item.product.shopify_id,
				name: [line_item.product.name, line_item.variant.shopify_title].join(' - '),
				grams: line_item.variant.weight * 28.35,
				price: line_item.price,
				total_discount: line_item.promo_total
			}
		end
	end

	def address(type)
		order_address = order.send(type)

		{
			first_name: order_address.firstname,
		  address1: order_address.address1,
		  phone: order_address.phone,
		  city: order_address.city,
		  zip: order_address.zipcode,
		  country: order_address.country.name,
		  last_name: order_address.lastname,
		  address2: order_address.address2,
		  country_code: order_address.country.iso,
		}
	end

	def shipping
		order.shipments.for_vendor(vendor).map do |shipment|
			{
				price: shipment.cost,
				discounted_price: shipment.discounted_cost,
				source: carrier_account(shipment),
				code: shipment.shipping_method.code,
				carrier_identifier: shipment.to_package.use_easypost? ? 'easypost' : '',
				title: shipment.shipping_method.name,
			}
		end
	end
    
  def carrier_account(shipment)
  	easy_post_rate_id = shipment.selected_shipping_rate.try(:easy_post_rate_id)
  	easy_post_rate_id.present? ? ::EasyPost::Rate.retrieve(easy_post_rate_id).carrier : ''
	end

	def order
		Spree::Order.find_by(id: @order_id)
	end

	def log_order(err = nil)
		log = Spree::SyncLog.create(
			provider: 'shopify', 
			action: 'order_export',
			message: err.present? ? err : nil,
			status: err.present? ? 'FAIL' : 'SUCCESS',
			syncable: order
		)
	end
end
