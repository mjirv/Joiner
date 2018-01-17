FactoryBot.define do
    factory :join_db do
        name { Faker::Lorem.word }
        user_id { Faker::Number.number(10) }
    end
end