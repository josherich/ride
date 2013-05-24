class RoutesController < InheritedResources::Base
	before_filter :find_route_record, :only => [:requestors, :favorite, :requests]
	respond_to :html, :js

	def index
		if params[:user_id]
			@routes = Route.per_user(params[:user_id])
		end
		@my_routes = current_user.routes
		respond_to do |format|
			format.js {}
		end
	end

	def create
		params[:route][:isactive] = true
		@route = current_user.routes.build(params[:route])

		# new route record
		if @route.save and user_signed_in?
			flash[:success] = "complete the route"
			redirect_to dashboard_path
		else
			flash[:alert] = "error in creating the route"
			redirect_to root_path
		end
	end

	def requestor
		@reqed_id = @route.id
		@requestors = @route.requestors
		respond_with(@requestors)
	end

	def search
		@results = Route.do_search(params)

		respond_with(@results) do |format|
			format.html { render :partial => 'route', :collection => @results, :as => :route}
			format.js {}
		end
	end

	def favorite
		if params[:type] == "unfavorite"
			current_user.unfollow!(@route)
		else
			current_user.follow!(@route)
		end
	end

	def requests
		@request = true
		if params[:type] == "unrequest"
			@request = false
			current_user.request_destroy(@route.id)
		else
			current_user.request_push(@route.id)
		end
	end

	private

	def find_route_record
		@route = Route.find(params[:id])
		rescue ActiveRecord::RecordNotFound
		flash[:alert] = "route not found"
		redirect_to dashboard_path
	end

end
