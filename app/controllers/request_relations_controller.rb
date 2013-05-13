class RequestRelationsController < ApplicationController
	before_filter :authenticate_user!
	
	def create
		@reqed_id = params[:reqed_id]
		@request_relation = current_user.request_relations.build(:reqed_id => params[:reqed_id], :stat_id => 1)
		
		@request_relation.save
		respond_to do |format|
			format.js
		end
	end

	def destroy
		@reqed_id = params[:reqed_id]
		@request_relation = RequestRelation.find(params[:id])
		@request_relation.destroy

		respond_to do |format|
			format.js
		end
	end

	def accept
		@request_relation = RequestRelation.find_by_id(params[:id])
		@reqed_id = RouteRecord.find_by_id(@request_relation.reqed_id).id

		@request_relation.update_attributes(:stat_id => 2)
		respond_to do |format|
			format.js
		end
	end

	def unaccept
		@request_relation = RequestRelation.find_by_id(params[:id])
		@reqed_id = RouteRecord.find_by_id(@request_relation.reqed_id).id

		@request_relation.update_attributes(:stat_id => 1)
		respond_to do |format|
			format.js
		end
	end

	def update_seats_stat(route_record)
		

	end


		
end
