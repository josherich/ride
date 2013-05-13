class RouteRecordsController < ApplicationController
	before_filter :authenticate_user!, :only => [:create, :destroy]
	respond_to :html, :js, :json

	def create
		params[:route_record][:isactive] = true

		from_str = params[:route_record][:from]
		to_str = params[:route_record][:to]
		from_co = [params[:route_record][:lng_s], params[:route_record][:lat_s]]
		to_co = [params[:route_record][:lng_d], params[:route_record][:lat_d]]

		@route_record = current_user.route_records.build(params[:route_record])

		# new search request
		if params[:search]
			@results = do_search(from_str, from_co, to_co)
			render 'search'
		end

		if !@route_record.save
			flash[:alert] = ""
			redirect_to root_path
		end

		# new route record
		if @route_record.save and user_signed_in?
			flash[:success] = "complete the route"
			redirect_to root_path
		# else
		# 	render 'users/show'
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
		reqed_id = params[:id]
		@route_record = RouteRecord.find(reqed_id)
		# @requests_relations = RequestRelation.where("reqed_id=" + reqed_id.to_s)
		# @match_requests = @route_record.requestors.where("stat_id = 1 OR accept_id = ?", reqed_id)

		respond_with(@route_record)
	end

	def requestors
		route_record = RouteRecord.find_by_id(params[:id])
		@reqed_id = route_record.id
		@requestors = route_record.requestors
		respond_with(@requestors)
	end

	# search api json
	def search
		radius_s = 10
		radius_d = 10
		from_str = params[:route_record][:from]
		to_str = params[:route_record][:to]
		from_p = [params[:route_record][:lat_s], params[:route_record][:lng_s]]
		to_p = [params[:route_record][:lat_d], params[:route_record][:lng_d]]

		search = Sunspot.search(RouteRecord) do
			with(:location_s).in_radius(from_p[0], from_p[1], radius_s)
			with(:location_d).in_radius(to_p[0], to_p[1], radius_d)
			order_by_geodist(:location_s, from_p[0], from_p[1])
		end
		@results = search.results
		respond_with(@results) do |format|
			format.html { render :partial => 'route_record', :collection => @results, :as => :route_record}
			format.js {}
			format.json
		end
	end

	# Parameters: {"utf8"=>"✓", "route_record"=>{"from"=>"上海市浦东新区晨晖路", "to"=>"上海市浦东新区峨山路陆家嘴软件园", "lng_s"=>"121.609634", "lat_s"=>"31.207321", "lng_d"=>"121.538711", "lat_d"=>"31.220777", "data"=>""}, "search"=>""}

	def edit
		@route_record = RouteRecord.find(params[:id])
		@title = "Edit route"
	end

	def update
		@route_record = RouteRecord.find(params[:id])

		respond_to do |format|
			if @route_record.update_attributes(params[:route_record])
				format.html { redirect_to @route_record, notice: 'Route was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @route_record.errors, status: :unprocessable_entity }
			end
		end
	end

	def destroy
		@route_record = RouteRecord.find(params[:id])
		@route_record.destroy

		respond_to do |format|
			format.html { redirect_to route_records_path }
			format.json { head :no_content }
		end
	end

	def do_search(from_str, from_co, to_co)
		search = RouteRecord.search do
			with(:location).in_radius(from_co[1], from_co[0], 100)
			order_by_geodist(:location, from_co[1], from_co[0])
		end
		results = search.results
		@match_from_count = search.total
		# search.results.each do |result|
		# 	this_co = [result[:lng_s], result[:lat_s]]
		# 	result[:distance] = distance_between(from_co, this_co)
		# end
		return results
	end
end
