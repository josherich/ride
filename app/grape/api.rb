require 'entities'

module Ride
  class API < Grape::API
    prefix "api"
    version "v1", using: :path
    format :json

    helpers do
      def current_user
        token = params[:token]
        @current_user ||= User.where(:authentication_token => token).first
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :users do
      get do
        @users = User.limit(20)
        present @users, :with => APIEntities::DetailUser
      end

      get ":user" do
        @user = User.where(:login => /^#{params[:id]}$/i).first
        present @user, :with => APIEntities::DetailUser
      end

      get ":user/routes" do
        @user = User.where(:login => /^#{params[:id]}$/i).first
        @routes = @user.routes
        present @routes, :with => APIEntities::Route
      end

      get ":user/fav" do
        @user = User.where(:login => /^#{params[:id]}$/i).first
        @fav = @user.following
        present @fav, :with => APIEntities::Route
      end

      get ":user/requests" do
        @user = User.where(:login => /^#{params[:id]}$/i).first
        @requests = @user.requesting
        present @requests, :with => APIEntities::Route
      end
    end


    resource :routes do
      # Get route record list
      # params[:page]
      # params[:per_page]
      get do
        @routes = Route.limit(20)
        present @routes, :with => APIEntities::Route
      end

      get ":id" do
        @route = Route.find(params[:id])
        present @route, :with => APIEntities::Route
      end

      get "search" do
        @results = Route.do_search(params)
        present @results, :with => APIEntities::Route
      end

      post ":id/favorite" do
        if params[:type] == "unfavorite"
          current_user.unfollow!(params[:id])
        else
          current_user.follow!(params[:id])
        end
      end

      post ":id/request" do
        if params[:type] == "unrequest"
          current_user.request_destroy(params[:id])
        else
          current_user.request_push(params[:id])
        end
      end

    end

    resource :request_relations do
      post ":id/accept" do
        if params[:type] == "unaccept"
          current_user.request_accept(params[:id])
        else
          current_user.request_unaccept(params[:id])
        end
      end
    end

    
  end
end
