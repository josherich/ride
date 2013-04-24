# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :match_relation do
    match_request_id 1
    route_id 1
  end
end
