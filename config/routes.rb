Rails.application.routes.draw do
  resources :avalon_items
  resources :people
  resources :performances
  resources :policies
  resources :recording_contributors
  resources :recordings do
    member do
      post 'mark_needs_review'
      post 'mark_reviewed'
    end
  end

  post '/nav/search', to: 'nav#mdpi_barcode_search', as: "mdpi_barcode_search"

  get '/atom_tester', to: 'atom_feed_reader#index', as: 'atom_feed_tester'
  get '/atom_tester/prepopulate', to: 'atom_feed_reader#prepopulate', as: 'atom_feed_prepopulate'
  get '/atom_tester/read_current', to: 'atom_feed_reader#read_current', as: 'atom_feed_read_current'
  get '/atom_tester/json/:id', to: 'atom_feed_reader#read_json', as: 'atom_feed_read_json'
  get '/atom_tester/load_avalon_record/:id', to: 'atom_feed_reader#load_avalon_record', as: 'load_avalon_record'

  # specify single barcode
  post '/services/access_decision_by_barcode/:mdpi_barcode', to: 'services#access_decision_by_barcode', as: 'access_decision_by_barcode'
  # specify json array of barcodes in request body
  post '/services/access_decision_by_barcodes', to: 'services#access_decision_by_barcodes', as: 'access_decision_by_barcodes'
  get '/services/access_decision_by_fedora_id/:fid', to: 'services#access_decision_by_fedora_id', as: 'access_decision_by_fedora_id'
  get '/services/access_decisions_by_barcodes', to: 'services#access_decisions_by_barcodes', as: 'access_decisions_by_barcodes'
  get '/services/access_decisions_by_fedora_ids', to: 'services#access_decisions_by_fedora_ids', as: 'access_decisions_by_fedora_ids'
  get '/services/access_decisions_tester', to: 'test#test_access_decisions', as: 'test_access_decisions'

  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/signoutg', to: 'sessions#destroy', via: :get

  resources :sessions, only: [:new, :destroy] do
    get :validate_login, on: :collection
  end

  get '/users/', to: 'user#index', as: 'users'
  post '/users/ajax/set_user_unit/:username/:unit/:access', to: 'user#ajax_set_user_unit', as: 'ajax_set_user_unit'
  get '/user/ldap_lookup', to: 'user#ldap_lookup', as: 'ldap_lookup'

  resources :works

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
