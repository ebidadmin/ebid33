Ebid33::Application.routes.draw do

  resources :surrenders

  resources :var_companies

  devise_for :users, path: :account, controllers: {sessions: "sessions"}
  
  # match 'users/:user_id/entries(/:page)' => 'entries#index', :as => :user_entries, :via => :get
  resources :users, :shallow => true do
    resources :entries
  end

  resources :entries, :shallow => true do
    member do
      get :put_online
      get :reveal
      get :relist
      get :reactivate
      get :print
    end
    resources :variances
  end

  resources :line_items do
    collection do
      get :add
      get :cancel
    end
  end

  get 'cart/add'
  get 'cart/remove'
  get 'cart/clear'

  resources :bids do
    collection do
      post :accept
    end
  end

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
  
  resources :messages do
    get :show_fields, on: :collection
    get :cancel, on: :collection
  end

  resources :car_models do
    get :selected, on: :member
  end
  resources :car_brands do
    get :selected, on: :member
  end
  resources :car_variants

  resources :car_parts do
    get :search, on: :collection
    get :add_more, on: :collection
  end

  resources :regions do
    get :selected, on: :member
  end
  
  resources :companies do
    get :selected, on: :member
  end
  
  scope 'seller' do
    get 'entries(/:s)' => 'seller#entries', as: :seller_entries
    get 'bids' => 'seller#bids', as: :seller_bids
    get 'worksheet' => 'seller#worksheet', as: :seller_worksheet
    get 'show/:id' => 'seller#show', as: :seller_show
    get 'orders(/:s(/:id))' => 'seller#orders', as: :seller_orders
    get 'fees(/:t)' => 'seller#fees', as: :seller_fees
  end
  
  scope 'buyer' do
    get 'entries(/:s)' => 'buyer#entries', as: :buyer_entries
    get 'show/:id' => 'buyer#show', as: :buyer_show
    get 'show/:id/print' => 'buyer#print_entry', as: :print_entry
    get 'reactivate/:id' => 'buyer#reactivate', as: :buyer_reactivate
    get 'orders(/:s(/:id))' => 'buyer#orders', as: :buyer_orders
    get 'fees(/:t)' => 'buyer#fees', as: :buyer_fees
    get 'surrender/:id' => 'buyer#surrender', as: :surrender_parts
    post 'surrender_letter/:id' => 'buyer#surrender_letter', as: :surrender_letter
  end
  
  scope 'admin' do
    get 'update_ratios' => 'admin#update_ratios', as: :update_ratios
    get 'expire_entries' => 'admin#expire_entries', as: :expire_entries
    get 'tag_payments' => 'admin#tag_payments', as: :tag_payments
    get 'send_payment_reminder' => 'admin#send_payment_reminder', as: :send_payment_reminder
    get 'delivery_reminder' => 'admin#delivery_reminder', as: :delivery_reminder
  end

  # match 'fees/:t' => 'fees#index', as: :fees
  # resources :fees do
  #   get :bprint, on: :collection
  # end
  
  scope 'fees' do
    get '/:t' => 'fees#index', as: :fees
    get '/:t/print' => 'fees#print', as: :print_fees
  end
  
  resources :fees
  resources :ratings
  resources :searches
  resources :branches

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
  #       get 'recent', on: :collection
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
