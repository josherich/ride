# coding: utf-8
class MatchRouteRecord
	include Sidekiq::Worker
	sidekiq_options :retry => false, :backtrace => true

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
		Notification.notify_all(user, "有新的路线匹配成功", text)
	end

	def new_match?(old_array, new_array)
		new_array - old_array
	end

	def make_notify_text(results)
		results[0].from + results[0].to
	end

	# def single_task
	# 	user = current_user
	# 	req = user.match_requests.first
	# 	req.match_clear
	# 	lat = req.lat_s
	# 	lng = req.lng_s
	# 	search = RouteRecord.search do
	# 		with(:location).in_radius(lat, lng, 3)
	# 		order_by_geodist(:location, lat, lng)
	# 	end
	# 	results = search.results
	# 	results.each do |r|
	# 		puts r.id
	# 		req.match_push(r.id)
	# 	end
	#   # RouteRecord.search.results.each do |res|
	#   #   req.match_push(res.id)
	#   # end
	# end


end