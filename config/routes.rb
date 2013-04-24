require 'sidekiq/web'

Ride::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end

  devise_for :users do
    get "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  # sidekiq admin load
  mount Sidekiq::Web, at: '/sidekiq'

  match 'dashboard', :to => 'home#dashboard'
  root :to => "home#index"

  # resources
  resources :users
  resources :users do
  	resources :route_records
  	resources :match_requests
  end

  resources :conversations do
    member do
      put 'trash', 'untrash', 'reply'
    end
  end
  resources :messages
  resources :notifications

  resources :route_records do
  	collection do
  		get 'search'
  	end
  end

  resources :route_records
  resources :fav_relations, :only => [:create, :destroy]
  resources :request_relations, :only => [:create, :destroy]
  resources :match_requests

end