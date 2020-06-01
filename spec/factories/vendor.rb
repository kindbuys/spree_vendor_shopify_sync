FactoryBot.define do
  factory :vendor, class: Spree::Vendor do
    sequence(:name) { |n| "vendor-#{n}" }
  end
end
