Spree::Core::Engine.add_routes do
  namespace :admin do
	  resource :shopify_sync, only: :show do
	    collection do
	      get :confirm
	      get :request_access
	      post :sync_product
	      post :delete_product
	      get :import_products
	      post :uninstall
	    end
	  end
	end

	resource :shopify, only: :show do
		get :install
		get :request_access
		get :confirm
		get :redact
	end
end

