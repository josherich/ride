collection @my_routes
node(false) { |route| partial('route_records/show', :object => :route)}