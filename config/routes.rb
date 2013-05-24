require 'sidekiq/web'

Ride::Application.routes.draw do
  require 'api'

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
  resources :routes do
    member do
      get 'requestors'
      post 'favorite'
      post 'requests'
    end
    collection do
      get 'search'
    end
  end

  resources :conversations do
    member do
      post 'trash'
      post 'reply'
    end
  end

  # resources :route_records do
  # 	collection do
  # 		get 'search'
  # 	end
  #   member do
  #     get 'requestors'
  #     post 'favorite'
  #   end
  # end

  resources :request_relations do
    member do
      post 'accept'
    end
  end

  resources :messages
  resources :notifications

  resources :fav_relations, :only => [:create, :destroy]
  resources :request_relations, :only => [:create, :destroy, :update]
  resources :match_requests

  mount Ride::API => "/"
  
  resources :users do
    resources :routes
    resources :match_requests
  end

  # if Rails.env.development?
  #   app = ActionDispatch::Static.new(
  #     lambda{ |env| [404, { 'X-Cascade' => 'pass'}, []] },
  #     Rails.application.config.paths['public'].first,
  #     Rails.application.config.static_cache_control
  #   )

  #   mount app, :at => '/', :as => :public
  # end

end