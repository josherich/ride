class MatchRequestsController < ApplicationController
	before_filter :authenticate_user!, :only => [:create, :destroy]
	respond_to :html, :json

	def create
		@request = current_user.match_requests.build(params[:match_request])
		if @request.save
			redirect_to dashboard_path
			return
		end
	end

	def index
		@match_requests = current_user.match_requests.all
		respond_to do |format|
			format.js
		end
	end

	# show searching results
	def show
		@match_request = current_user.match_requests.find_by_id(params[:id])
		@match_results = @match_request.match_route

		respond_to do |format|
			format.js
		end
	end

	def destroy
		@match_request = MatchRequest.find(params[:id])
		@match_request.destroy

		respond_to do |format|
			format.html { redirect_to user_path(4) }
			format.json { head :no_content }
		end
	end

end
