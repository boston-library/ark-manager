Rails.application.routes.draw do
  resources :arks, only: [:show, :create, :destroy], constraints: { format: 'json' }

  match '/:ark/:namespace/:noid' => 'arks#object_in_view', :as => 'object_in_view', :constraints => {:ark => /ark:/}, via: [:get, :post]

  # match '/delete_ark' => 'arks#de', :as => 'delete_ark', via: [:post]


  #TODO Move these to curator or front end app/ commonwealth-vlr-engine
  # match '/:ark/:namespace/:noid/thumbnail' => 'preview#thumbnail', :as => 'thumbnail', :constraints => {:ark => /ark:/}, via: [:get, :post]

  # match '/:ark/:namespace/:noid/full_image' => 'preview#full_image', :as => 'full_image', :constraints => {:ark => /ark:/}, via: [:get]
  #
  # match '/:ark/:namespace/:noid/large_image' => 'preview#large_image', :as => 'large_image', :constraints => {:ark => /ark:/}, via: [:get]
  #
  # match '/:ark/:namespace/:noid/manifest' => 'arks#iiif_manifest', :as => 'iiif_manifest', :constraints => {:ark => /ark:/}, via: [:get]
  #
  # match '/:ark/:namespace/:noid/canvas/:canvas_object_id' => 'arks#iiif_canvas', :as => 'iiif_canvas', :constraints => {:ark => /ark:/}, via: [:get]
  #
  # match '/:ark/:namespace/:noid/annotation/:annotation_object_id' => 'arks#iiif_annotation', :as => 'iiif_annotation', :constraints => {:ark => /ark:/}, via: [:get]
  #
  # match '/:ark/:namespace/collection/:noid' => 'arks#iiif_collection', :as => 'iiif_collection', :constraints => {:ark => /ark:/}, via: [:get]
  #
  # match '/:ark/:namespace/:noid/iiif_search' => 'arks#iiif_search', :as => 'iiif_search', :constraints => {:ark => /ark:/}, via: [:get]

end
