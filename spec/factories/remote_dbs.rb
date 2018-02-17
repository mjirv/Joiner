FactoryBot.define do
    factory :remote_db do
        name { Faker::Lorem.word }
        db_type ["mysql", "postgres", "sql_server", "redshift"].sample
        database_name { Faker::Lorem.word }
        schema { Faker::Lorem.word }
        host { Faker::Internet.private_ip_v4_address }
        port { Faker::Number.number(4)}
        remote_user { Faker::Internet.user_name }
        password { Faker::Internet.password }
    end
end