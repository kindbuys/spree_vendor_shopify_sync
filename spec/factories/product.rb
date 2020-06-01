FactoryBot.define do
  factory :product, class: Spree::Product do
  	sequence(:name) { |n| "product-#{n}" }
  	shipping_category { Spree::ShippingCategory.last || association(:shipping_category) }
  	price { 1 }
  end
end
