require 'rails_helper'

#FactoryBot.find_definitions

describe RemoteDb do

    before(:all) do 
        user_attributes = FactoryBot.attributes_for(:user)
        join_db_attributes = FactoryBot.attributes_for(:join_db)
        
        user = User.create!(user_attributes)

        join_db_attributes[:user_id] = user.id
        join_db = JoinDb.create!(join_db_attributes)
    end

    describe "Viewing a RemoteDb", type: :request do
        it "denies access if you're not logged in"

        it "denies access if you're the wrong user"

        it "succeeds if you're logged in and the right user"
    end

    describe "Creating a RemoteDb", type: :request do
        it "denies access if you're not logged in" 

        it "denies access if you're the wrong user"

        it "succeeds if you're logged in and the right user"

        it "is given a host and port on creation"
    end

    describe "Deleting a RemoteDb", type: :request do
        it "deletes the JoinDB if you're logged in and the right user"

        it "fails if you're not logged in"

        it "fails if you're the wrong user"
    end
end