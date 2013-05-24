class FavRelation < ActiveRecord::Base
  attr_accessible :follower_id, :route_id

  belongs_to :follower, :class_name => "User"
  belongs_to :route, :class_name => "Route"

  validates :follower_id, :presence => true
  validates :route_id, :presence => true
  
end
