class RouteRecordsController < ApplicationController
	before_filter :authenticate_user!, :only => [:create, :destroy]
	before_filter :find_route_record, :only => [:show, :edit, :update, :destroy, :requestors, :favorite]
	
	respond_to :html, :js, :json

	def create
		params[:route_record][:isactive] = true
		@route_record = current_user.route_records.build(params[:route_record])

		# new route record
		if @route_record.save and user_signed_in?
			flash[:success] = "complete the route"
			redirect_to dashboard_path
		else
			flash[:alert] = "error in creating the route"
			redirect_to root_path
		end
	end

	def index
		@title = "route_records"
		
		if params[:user_id]
			@route_records = RouteRecord.where(:user_id => params[:user_id]).paginate(:page => params[:page])
		end
		@my_routes = current_user.route_records
		respond_to do |format|
			format.js {}
		end
	end

	def show
		@route_record = RouteRecord.find(params[:id])
		
		respond_with(@route_record)
	end

	def requestors
		@reqed_id = @route_record.id
		@requestors = @route_record.requestors
		respond_with(@requestors)
	end

	# js search
	def search
		@results = RouteRecord.do_search(params)

		respond_with(@results) do |format|
			format.html { render :partial => 'route_record', :collection => @results, :as => :route_record}
			format.js {}
		end
	end

	# Parameters: {"utf8"=>"✓", "route_record"=>{"from"=>"上海市浦东新区晨晖路", "to"=>"上海市浦东新区峨山路陆家嘴软件园", "lng_s"=>"121.609634", "lat_s"=>"31.207321", "lng_d"=>"121.538711", "lat_d"=>"31.220777", "data"=>""}, "search"=>""}

	def edit
		@title = "Edit route"
	end

	def update
		respond_to do |format|
			if @route_record.update_attributes(params[:route_record])
				format.html { redirect_to @route_record, notice: 'Route was successfully updated.' }
			else
				format.html { render action: "edit" }
			end
		end
	end

	def destroy
		@route_record.destroy

		respond_to do |format|
			format.js {}
		end
	end

	def favorite
		if params[:type] == "unfavorite"
			current_user.unfollow!(@route_record)
		else
			current_user.follow!(@route_record)
		end
	end

	def request
		if params[:type] == "unrequest"
			current_user.request_destroy(@route_record.id)
		else
			current_user.request_push(@route_record.id)
		end
	end

	private

	def find_route_record
		@route_record = RouteRecord.find(params[:id])
		rescue ActiveRecord::RecordNotFound
		flash[:alert] = "route not found"
		redirect_to dashboard_path
	end
end
