require 'nokogiri'
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
    
    @new_route = RouteRecord.new
    # sync_update @route_records

    # perform
  	respond_to do |format|
  		format.html
  		format.json { render json:current_user }
  	end
    # RouteRecordCrawler.perform_async
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

  def init
    @url = ["http://shanghai.baixing.com/shangxiabanpinche/",
      "http://sh.ganji.com/pincheshangxiaban/",
      "http://sh.58.com/pinche/"]
    @opt = []
  
    @locate_list = ["#pinned-list ul li p a", ".layoutlist dl dt > a", "#infolist table tr td > a"]
    @locate_detail = ["#meta-table tr"]
    @norm_reg = []

    @sel_key = []
    @sel_value = []
  end

  def perform
    init
    @page = read(@url[0], "")
    @list = link_list(@page, @locate_list[0])

    detail_page = read(@list[0], "")

    detail = parse_detail(detail_page, @locate_detail[0], "td")
    logger.debug "detail:"
    logger.info @list
    # logger.info detail_page
    logger.info detail
  end


  def read(url, opt)
    page = Nokogiri::HTML(open(url + opt))
  end

  def link_list(page, locate)
    a = []
    page.css(locate).each do |link|
      a.push(link['href'])
    end
    return a
  end

  def parse_detail(page, locate, sel_key)
    data = Hash.new
    page.css(locate).each do |list|
      key = norm(list.css(sel_key)[0].content)
      value = norm(list.css(sel_key)[1].content)
      logger.info value
      data[key] = value
    end
    return data
  end

  def norm(str)
    str.gsub(/\n/, "")
    str
  end


end
