class RequestRelationsController < ApplicationController
	before_filter :authenticate_user!
	
	def create
		if params[:opt] == 'direct'
			params[:match_request][:from] = params[:from]
			params[:match_request][:to] = params[:to]
			@new_request = current_user.match_requests.build(params[:match_request])
			@route_record = RouteRecord.find_by_id(params[:route_id])
			@new_request.request_push(params[:route_id], 1)
		else

			@route_record = RouteRecord.find_by_id(params[:reqed_id])
			@match_request = MatchRequest.find_by_id(params[:req_id])
			if !@match_request.request_sent?(params[:reqed_id])
				@match_request.request_push(params[:reqed_id], 1)
			end
		end

		respond_to do |format|
			format.js
		end
	end

	def destroy
		if params[:opt] == 'direct'
			tmp_request_relation = RequestRelation.find_by_id(params[:id])
			tmp_request_relation.destroy
		else
			route_id = RequestRelation.find_by_id(params[:id]).reqed_id
			@route_record = RouteRecord.find_by_id(route_id)

			request_id = RequestRelation.find_by_id(params[:id]).req_id
			@match_request = MatchRequest.find_by_id(request_id)
			@match_request.request_destroy(route_id)
		end
		respond_to do |format|
			format.js
		end
	end

	def accept
		
		@relation = RequestRelation.find_by_id(params[:id])
		@route_record = RouteRecord.find_by_id(@relation.reqed_id)
		@all_relations = RequestRelation.where("req_id = ?", @relation.req_id)
		toggle_accept_stat(@all_relations, @route_record)

		# update_seats_stat(@route_record)
		# logger.info "@@@@@@@@@@@@@"
		# logger.info params[:test]
		# logger.info @relation.stat_id

		respond_to do |format|
			format.js
		end
	end

	# uninitialize: 1
	# accept:2
	def toggle_accept_stat(relations, route_record)
		if relations.first.stat_id == 1
			relations.each do |r|
				r.update_attributes(:stat_id => 2, :accept_id => route_record.id)
			end
		else
			relations.each do |r|
				r.update_attributes(:stat_id => 1, :accept_id => 0)
			end
		end
	end

	def update_seats_stat(route_record)
		

	end


		
end
