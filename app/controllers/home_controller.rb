class HomeController < ApplicationController
  def index
    @title = "Home"
    @users = User.all
    @route_record = RouteRecord.new
    @match_request = MatchRequest.new
  end

  def dashboard
  	@title = 'Dashboard'

    @user = current_user
  	@route_records = current_user.route_records
  	@match_requests = current_user.match_requests
  	@following = current_user.following
  	@match_count = match_count
    
  	respond_to do |format|
  		format.html
  		format.json { render json:current_user }
  	end

    MatchRouteRecord.perform_async

  	rescue ActiveRecord::RecordNotFound
  	  redirect_to root_path
  end

  def destroy
  end

  private

  def match_count
  	count = 0
  	@match_requests.each do |m|
  	  count += m.match_route.count
  	end
  	return count
  end


end
