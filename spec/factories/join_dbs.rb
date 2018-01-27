FactoryBot.define do
    factory :join_db do
        name { Faker::Lorem.word }
        user_id { Faker::Number.between(1,10000) }
    end
end