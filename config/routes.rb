# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  resource  :session, only: %i[new create destroy]
  resources :games, only: %i[index show create] do
    resources :moves, only: %i[create]
    member do
      post :join
      post :start
      post :rematch
    end
    collection do
      get :code, to: 'games#find_by_code' # optional: join via 6-char code
    end
  end
  root 'games#index'
end
