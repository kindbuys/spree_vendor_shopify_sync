FactoryBot.define do
  factory :shipping_category, class: Spree::ShippingCategory do
    sequence(:name) { |n| "shipping-category-#{n}" }
    default { Spree::ShippingCategory.default.present? ? false : true }
  end
end
