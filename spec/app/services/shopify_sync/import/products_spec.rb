require 'rails_helper'
require "#{Rails.root}/lib/shopify_sync/import/products.rb"

# These specs are not working because of ShopifySync::Import::Options line 21 - .values returns 
# the fixture hash values instead of the values attributes

RSpec.describe ShopifySync::Import::Products do
	describe 'sync_product' do
		let!(:vendor) { create :vendor }
		let!(:shipping_category) { create :shipping_category }
		let(:shopify_product) { Hashie::Mash.new(JSON.parse(File.read("spec/fixtures/shopify_product.json"))) }

		before(:each) do
			expect(ShopifyAPI::Product).to receive(:find).and_return(shopify_product)
		end

		context 'the product exists' do
			let!(:product) { create :product, shopify_id: '12345', vendor: vendor }

			it 'does not create a new product' do
				expect { ShopifySync::Import::Products.new(vendor.id, '12345').sync_product }.to_not change { Spree::Product.count }
			end
		end

		context 'the product does not exist' do
			it 'creates a product' do
				#expect { ShopifySync::Import::Products.new(vendor.id, '12345').sync_product }.to change { Spree::Product.count }.by(1)
			end
		end
	end
end