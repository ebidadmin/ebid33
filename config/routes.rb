Ebid33::Application.routes.draw do

  resources :users

  resources :ratings

  devise_for :users, path: :account
  
  # match 'users/:user_id/entries(/:page)' => 'entries#index', :as => :user_entries, :via => :get
  resources :users do
  end

  resources :entries, :shallow => true do
    member do
      get :put_online
      get :reveal
      get :relist
      get :reactivate
      get :print
    end
  end

  get 'cart/add'
  get 'cart/remove'
  get 'cart/clear'

  
  resources :fees

  resources :messages do
    get :show_fields, :on => :collection
    get :cancel, :on => :collection
  end

  resources :line_items

  resources :orders do
    member do
      get :accept
      get :change_status
      put :buyer_paid
      get :print
      get :cancel
      put :confirm_cancel
    end
    collection do
      get :auto_paid
    end
    resources :ratings
  end

  resources :bids do
    collection do
      post :accept
    end
  end

  resources :searches

  resources :branches

  resources :companies

  resources :car_models do
    get :selected, :on => :member
  end
  resources :car_brands do
    get :selected, :on => :member
  end
  resources :car_variants
  resources :car_parts do
    get :search, :on => :collection
    get :add_more, :on => :collection
  end

  resources :regions do
    get :selected, :on => :member
  end
  #get \"users\/show\"

  root :to => "home#index"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
