Rails.application.routes.draw do
  resources :works
  resources :people
  resources :performances
  resources :policies
  resources :recording_contributors
  resources :recordings

  post '/nav/search', to: 'nav#mdpi_barcode_search', as: "mdpi_barcode_search"

  get '/services/access_decision_by_barcode/:mdpi_barcode', to: 'services#access_decision_by_barcode', as: 'access_decision_by_barcode'
  get '/services/access_decision_by_fedora_id/:fid', to: 'services#access_decision_by_fedora_id', as: 'access_decision_by_fedora_id'
  get '/services/access_decisions_by_barcodes', to: 'services#access_decisions_by_barcodes', as: 'access_decisions_by_barcodes'
  get '/services/access_decisions_by_fedora_ids', to: 'services#access_decisions_by_fedora_ids', as: 'access_decisions_by_fedora_ids'

  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete

  resources :sessions, only: [:new, :destroy] do
    get :validate_login, on: :collection
  end

  get '/user/ldap_lookup', to: 'user#ldap_lookup', as: 'ldap_lookup'

  root 'nav#start'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
