# coding: utf-8
require 'nokogiri'
class HomeController < ApplicationController
  before_filter :get_conversations

  def index
    @title = "Home"
  end

  def dashboard
  	@title = 'Dashboard'

    @user = current_user
    @route_records = current_user.route_records
    @match_requests = current_user.match_requests
    
    # @requests = RequestRelation.find(req_ids)

    @following = current_user.following
    @match_count = match_count
    
    @new_route = RouteRecord.new
    # sync_update @route_records

    perform
    respond_to do |format|
      format.html
      format.json { render json:current_user }
    end
    # RouteRecordCrawler.perform_async
    # MatchRouteRecord.perform_async
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def timechart
   case params[:view]
   when "match_results"
     @match_request = current_user.match_requests.find_by_id(params[:id])
     @match_results = @match_request.match_route
     render 'route_records/route_record_chart'
   when "requests"
   end
  end



 def destroy
 end

 private
 def perform
  @radius = 10 # 2km
  User.all.each do |user|
    match_task(user)
  end
 end

 def match_task(user)
  user.match_requests.each do |req|
    search = search_radius([req.lat_s, req.lng_s], [req.lat_d, req.lng_d], @radius)
    results = search.results
    logger.info results

    old_array = req.match_route.map {|r| r.id}
    logger.info old_array
    
    new_array = results.map {|r| r.id}
    logger.info new_array

    update_match_relations(req, new_array)
    
    if new_match?(old_array, new_array)
      text = make_notify_text(results)
      notify_update(user, text)
    end
  end
 end

 def search_radius(src, des, radius)
  search = Sunspot.search(RouteRecord) do
    with(:location_s).in_radius(src[0], src[1], radius)
    with(:location_d).in_radius(des[0], src[1], radius)
  end
  return search
 end

 def update_match_relations(match_request, match_array)
  match_request.match_clear

  match_array.each do |m|
    match_request.match_push(m)
  end
 end

 def notify_update(user, text)
  Notification.notify_all(user, "有新的路线匹配成功", text, nil, true, nil)
 end

 def new_match?(old_array, new_array)
  new_array - old_array
 end

 def make_notify_text(results)
  route_record = RouteRecord.find_by_id(18)
  route_record.from + route_record.to
 end


 def get_conversations
  @notifications = current_user.mailbox.notifications.unread
  end

def match_count
 count = 0
 @match_requests.each do |m|
   count += m.match_route.count
 end
 return count
end

end
