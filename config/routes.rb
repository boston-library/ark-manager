# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#app_info'

  mount Rswag::Api::Engine => 'api-docs'

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
    scope '/:ark/:namespace/:noid', constraints: { ark: /ark:/ } do
      scope defaults: { object_in_view: true } do
        controller 'arks' do
          root action: 'show', as: 'object_in_view', via: [:get, :post]
          get '/manifest', action: 'iiif_manifest', as: 'iiif_manifest'
          get '/canvas/:canvas_object_id', action: 'iiif_canvas', as: 'iiif_canvas'
          get '/annotation/:annotation_object_id', action: 'iiif_annotation', as: 'iiif_annotation'
          get '/iiif_collection', action: 'iiif_collection', as: 'iiif_collection'
          get '/iiif_search', action: 'iiif_search', as: 'iiif_search'
        end
      end

      controller 'preview' do
        match '/thumbnail', action: 'thumbnail', as: 'thumbnail', via: [:get, :post]
        get '/full_image', action: 'full_image', as: 'full_image'
        get '/large_image', action: 'preview#large_image', as: 'large_image'
      end

      match '*path' => 'application#route_not_found', via: [:all]
    end
  end

  match '*path' => 'application#route_not_found', via: [:all]
end
