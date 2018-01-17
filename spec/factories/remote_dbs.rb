FactoryBot.define do
    factory :remote_db do
        name { Faker::Lorem.word }
        db_type { Faker::Number.number(1) }
    end
end