class RequestRelation < ActiveRecord::Base
  attr_accessible :req_id, :reqed_id, :stat_id, :accept_id

  belongs_to :req, :class_name => "MatchRequest"
  belongs_to :reqed, :class_name => "RouteRecord"

  validates :req_id, :presence => true
  validates :stat_id, :presence => true
  validates :reqed_id, :presence => true

end
