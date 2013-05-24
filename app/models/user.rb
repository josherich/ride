class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :authentication_token
  
  acts_as_messageable

  has_many :routes, :dependent => :destroy
  has_many :match_requests, :dependent => :destroy

  has_many :fav_relations, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :fav_relations, :source => :route

  has_many :request_relations, :foreign_key => "req_id", :dependent => :destroy
  has_many :requesting, :through => :request_relations, :source => :reqed
  
  def name
  	return :name
  end

  def mailboxer_email(object)
  	return :email
  end

  # follow route
  def following?(route)
  	fav_relations.find_by_route_id(route.id)
  end

  def follow!(route)
  	fav_relations.create!(:route_id => route.id	)
  end

  def unfollow!(route)
  	fav_relations.find_by_route_id(route.id).destroy
  end


  # send request
  def requested?(reqed_id)
    request_relations.find_by_reqed_id(reqed_id)
  end

  def request_push(reqed_id)
    request_relations.create!(:reqed_id => reqed_id, :stat_id => 1)
  end

  def request_destroy(reqed_id)
    request_relations.find_by_reqed_id(reqed_id).destroy
  end


  # accept request
  def request_accept(relation)
    request_relation = RequestRelation.find_by_id(relation)

    # TODO disable conflicts request once accpeted by one
    if route_records.find_by_id(request_relation.reqed_id)
      request_relation.update_attributes(:stat_id => 2)
    end
  end

  def request_unaccept(relation)
    request_relation = RequestRelation.find_by_id(relation)
    
    if route_records.find_by_id(request_relation.reqed_id)
      request_relation.update_attributes(:stat_id => 1)
    end
  end


end
