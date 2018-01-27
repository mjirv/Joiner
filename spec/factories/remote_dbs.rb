FactoryBot.define do
    factory :remote_db do
        name { Faker::Lorem.word }
        db_type { Faker::Number.between(0,2) }
    end
end