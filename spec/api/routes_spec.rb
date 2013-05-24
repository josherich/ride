require 'spec_helper'

describe Ride::API, 'routes' do
	describe "GET /api/routes.json" do
		it "should be ok" do
			get "/api/v1/routes.json"
			response.status.should == 200
		end
	end
end
