class RouteRecord < ActiveRecord::Base
  attr_accessible :data, :from, :to, :user_id, :lng_s, :lat_s, :lng_d, :lat_d, :set_time, :set_date, :timespan, :freq_pattern, :seat_stat, :price, :isactive, :isdriver

  belongs_to :user
  
  has_many :fav_relations, :foreign_key => "route_id", :dependent => :destroy
  has_many :match_relations, :foreign_key => "route_id", :dependent => :destroy

  validates :from, :presence => true, :length => { :maximum => 20 }
  validates :to, :presence => true, :length => { :maximum => 20 }

  searchable :auto_index => true, :auto_remove => false do
  	text :from, :to
  	text :data
  	double	:lng_s
  	double	:lat_s
  	double	:lng_d
  	double	:lat_d
  	time	:created_at
  	latlon(:location) {
  		Sunspot::Util::Coordinates.new(lat_s, lng_s)
  	}
  end

  default_scope :order => 'route_records.created_at DESC'
end
