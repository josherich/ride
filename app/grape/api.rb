module Ride
  class API < Grape::API
    prefix "api"
    version "v1"

    helpers do
      def current_user
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    # Authentication:
    # APIs marked as 'require authentication' should be provided the user's private token,
    # either in post body or query string, named "token"

    resource :route_records do
      # Get route record list
      # params[:page]
      # params[:per_page]
      get do
        @route_records = RouteRecord.all.paginate(:page => params[:page], :per_page => params[:per_page] || 30)
      end

      get "user/route_records/"
    end

    
  end
end
