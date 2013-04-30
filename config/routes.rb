require 'sidekiq/web'

Ride::Application.routes.draw do
  root :to => "home#index"
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  authenticated :user do
    root :to => 'home#index'
  end

  devise_for :users do
  ActiveAdmin.routes(self)
    get "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  # sidekiq admin load
  mount Sidekiq::Web, at: '/sidekiq'

  match 'dashboard', :to => 'home#dashboard'


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

  resources :request_relations do
    member do
      put 'accept'
    end
  end
  

  resources :route_records
  resources :fav_relations, :only => [:create, :destroy]
  resources :request_relations, :only => [:create, :destroy, :update]
  resources :match_requests

end