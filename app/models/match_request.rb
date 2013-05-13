class MatchRequest < ActiveRecord::Base
  attr_accessible :arrive_time, :freq_pattern, :from, :to, :lat_s, :lng_s, :lat_d, :lng_d

  belongs_to :user
  
  has_many :match_relations, :foreign_key => "match_request_id", :dependent => :destroy
  has_many :match_route, :through => :match_relations, :source => :route

  def match_push(route_id)
  	match_relations.create!(:route_id => route_id)
  end

  def match_clear
  	match_relations.each do |m|
  		m.destroy
  	end
  end

  # def request_push(route_id, stat_id)
  #   if requesting.include?(RouteRecord.find(route_id))
  #     return false
  #   end
  #   request_relations.build(:reqed_id => route_id, :stat_id => stat_id)
  # end

  # def request_destroy(route_id)
  #   request_relations.find_by_reqed_id(route_id).destroy
  # end
end
