require 'spec_helper'

describe Ride::API, 'users' do
	describe "GET /api/v1/users.json" do
		it "should be ok" do
			get "/api/v1/users.json"
			response.status.should == 200
		end
	end
end