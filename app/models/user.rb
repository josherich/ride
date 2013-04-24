class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  acts_as_messageable

  # attr_accessor :password
  # attr_accessible :email, :name, :password, :password_confirmation

  has_many :route_records, :dependent => :destroy
  has_many :match_requests, :dependent => :destroy

  has_many :fav_relations, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :fav_relations, :source => :route

  def name
  	return :name
  end

  def mailboxer_email(object)
  	return :email
  end

  def following?(route)
  	fav_relations.find_by_route_id(route)
  end

  def follow!(route)
  	fav_relations.create!(:route_id => route.id	)
  end

  def unfollow!(route)
  	fav_relations.find_by_route_id(route).destroy
  end

end
