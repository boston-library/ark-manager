# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#app_info'

  scope 'api', defaults: { format: :json } do
    scope ':version', constraints: VersionConstraint do
      constraints(->(req) { req.format.json? }) do
        resources :arks, only: [:show, :destroy], constraints: IdOrPidConstraint.new
        resources :arks, only: [:create]
      end
    end

    match '*path' => 'application#route_not_found', via: [:all]
  end

  scope constraints: ->(req) { !req.format.json? } do
    match '/:ark/:namespace/:noid' => 'arks#show',
          as: 'object_in_view',
          constraints: { ark: /ark:/ },
          defaults: { object_in_view: true },
          via: [:get, :post]
  end
  match '*path' => 'application#route_not_found', via: [:all]
  mount Rswag::Api::Engine => 'api-docs'

  # TODO: Move these to curator or front end app/ commonwealth-vlr-engine
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
