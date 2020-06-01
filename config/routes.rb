Spree::Core::Engine.add_routes do
  namespace :admin do
	  resource :shopify_sync, only: :show do
	    collection do
	      get :confirm
	      get :request_access
	      post :sync_product
	      post :delete_product
	      get :import_products
	    end
	  end
	end
end
