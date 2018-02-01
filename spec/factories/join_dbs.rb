FactoryBot.define do
    factory :join_db do
        name { Faker::Lorem.word }
        username { Faker::Internet.user_name }
        password { Faker::Internet.password }
    end
end