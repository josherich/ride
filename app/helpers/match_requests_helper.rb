module MatchRequestsHelper
	def init
		rel = RequestRelation.where("req_id=?", @match_request.id)
		stat = 0
		stat = rel.first.stat_id if rel
		accept_id = RequestRelation.where("req_id=?", @match_request.id).first.accept_id
	end

	def other_match_sent?(route_id)
	  current_user.match_requests.each do |r|
	    if r.request_sent?(route_id)
	      return true
	    end
	  end
	  return false
	end
end


