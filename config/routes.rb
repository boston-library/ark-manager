require 'resque/server'

ArkHandler::Application.routes.draw do
  resources :arks

  mount Resque::Server.new, :at => "/resque"

  match '/:ark/:namespace/:noid/thumbnail' => 'preview#thumbnail', :as => 'thumbnail', :constraints => {:ark => /ark:/}, via: [:get, :post]

  match '/:ark/:namespace/:noid' => 'arks#object_in_view', :as => 'object_in_view', :constraints => {:ark => /ark:/}, via: [:get, :post]

  match '/delete_ark' => 'arks#delete_ark', :as => 'delete_ark', via: [:post]

  match '/:ark/:namespace/:noid/full_image' => 'preview#full_image', :as => 'full_image', :constraints => {:ark => /ark:/}, via: [:get]

  match '/:ark/:namespace/:noid/large_image' => 'preview#large_image', :as => 'large_image', :constraints => {:ark => /ark:/}, via: [:get]

  match '/:ark/:namespace/:noid/manifest' => 'arks#iiif_manifest', :as => 'iiif_manifest', :constraints => {:ark => /ark:/}, via: [:get]

  match '/:ark/:namespace/:noid/canvas/:canvas_object_id' => 'arks#iiif_canvas', :as => 'iiif_canvas', :constraints => {:ark => /ark:/}, via: [:get]

  match '/:ark/:namespace/:noid/annotation/:annotation_object_id' => 'arks#iiif_annotation', :as => 'iiif_annotation', :constraints => {:ark => /ark:/}, via: [:get]

  match '/:ark/:namespace/collection/:noid' => 'arks#iiif_collection', :as => 'iiif_collection', :constraints => {:ark => /ark:/}, via: [:get]



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
  # match ':controller(/:action(/:id))(.:format)'
end
