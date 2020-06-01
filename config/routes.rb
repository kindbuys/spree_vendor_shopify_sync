Rails.application.routes.draw do
  #root :to => 'home#index'
  get "/admin/shopify_sync", to: "home#index"
  mount ShopifyApp::Engine, at: '/admin/shopify_sync'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
