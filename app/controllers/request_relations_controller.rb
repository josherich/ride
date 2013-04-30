class RequestRelationsController < ApplicationController
	before_filter :authenticate_user!
	
	def create
		@route_record = RouteRecord.find_by_id(params[:request_relation][:reqed_id])
		@match_request = MatchRequest.find_by_id(params[:request_relation][:req_id])
		if !@match_request.request_sent?(params[:request_relation][:reqed_id])
			@match_request.request_push(params[:request_relation][:reqed_id], 1)
		end

		respond_to do |format|
			format.js
		end
	end

	def destroy
		route_id = RequestRelation.find_by_id(params[:id]).reqed_id
		@route_record = RouteRecord.find_by_id(route_id)

		request_id = RequestRelation.find_by_id(params[:id]).req_id
		@match_request = MatchRequest.find_by_id(request_id)
		@match_request.request_destroy(route_id)
		respond_to do |format|
			format.js
		end
	end

	def accept
		
		@relation = RequestRelation.find_by_id(params[:id])
		@route_record = RouteRecord.find_by_id(@relation.reqed_id)

		toggle_accept_stat(@relation)

		# update_seats_stat(@route_record)

		# logger.info "@@@@@@@@@@@@@"
		# logger.info params[:test]
		# logger.info @relation.stat_id

		respond_to do |format|
			format.js
		end
	end

	def toggle_accept_stat(relation)
		if relation.stat_id == 1
			relation.update_attributes(:stat_id => 2)
		else
			relation.update_attributes(:stat_id => 1)
		end
	end

	def update_seats_stat(route_record)
		

	end


		
end
