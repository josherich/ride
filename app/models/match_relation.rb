class MatchRelation < ActiveRecord::Base
  attr_accessible :match_request_id, :route_id

  belongs_to :match_request, :class_name => "MatchRequest"
  belongs_to :route, :class_name => "RouteRecord"

  validates :match_request_id, :presence => true
  validates :route_id, :presence => true
  
end
