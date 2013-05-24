require "digest/md5"

module Ride
	module APIEntities
		class User < Grape::Entity
			expose :id, :login
		end

		class DetailUser < Grape::Entity
			expose :id, :name, :login, :email
			expose(:routes, :unless => { :collection => true }) do |model, opts|
				model.routes.as_json(:only => [:id, :from, :to, :created_at])
			end
		end

		class Route < Grape::Entity
			expose :id, :from, :to, :user_id, :set_date, :set_time, :freq_pattern, :lng_s, :lat_s, :lng_d, :lat_d,:seat_stat, :price, :timespan
		end
	end
end