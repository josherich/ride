class RequestRelationsController < ApplicationController
	before_filter :authenticate_user!

	def accept
		if params[:type] == "unaccept"
			@request_relation = current_user.request_unaccept(params[:id])
		else
			@request_relation = current_user.request_accept(params[:id])
		end

		@reqed_id = @request_relation.reqed_id

		respond_to do |format|
			format.js
		end
	end

	# TODO
	def update_seats_stat(route_record)

	end


		
end
