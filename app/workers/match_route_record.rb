class MatchRouteRecord
	include Sidekiq::Worker
	sidekiq_options :retry => false, :backtrace => true

	def perform
		@radius = 10 # 2km
		User.all.each do |user|
			match_task(user.id)
		end
	end

	def match_task(user_id)
		user = User.find_by_id(user_id)
		user.match_requests.each do |req|
			search = search_radius(req.lat_s, req.lng_s, @radius)
			results = search.results

			match_array = []
			results.each do |res|
				match_array.push(res.id)
			end
			update_match_relations(req.id, match_array)
		end
	end

	def search_radius(lat, lng, radius)
		search = RouteRecord.search do
			with(:location).in_radius(lat, lng, radius)
			order_by_geodist(:location, lat, lng)
		end
		return search
	end

	def update_match_relations(match_request_id, match_array)
		match_request = MatchRequest.find_by_id(match_request_id)
		match_request.match_clear

		match_array.each do |m|
			match_request.match_push(m)
		end
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