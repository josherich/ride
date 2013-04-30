require 'nokogiri'
require 'open-uri'

class RouteRecordCrawler
	include Sidekiq::Worker
	sidekiq_options :retry => false, :backtrace => true

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
		page = read(@url[0], "")
		list = link_list(page, @locate_list[0])
		detail = parse_detail(list[0], @locate_detail[0], "td:first", "td:last")
		logger.debug "detail:"
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
	end

	def parse_detail(list, locate, sel_key, sel_value)
		data = []
		list.css(locate).each do |list|
			key = norm(list.css(sel_key).first.content)
			value = norm(list.css(sel_value).first.content)
			data.push(key=>value)
		end
	end

	def norm(str)
		str.gsub(/\n/, "")
		str
	end
end

