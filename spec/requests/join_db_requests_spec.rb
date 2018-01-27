require 'rails_helper'

#FactoryBot.find_definitions

describe "Viewing a JoinDb", type: :request do
    it "denies access if you're not logged in" do
        user_attributes = FactoryBot.attributes_for(:user)
        user = User.create!(user_attributes)

        join_db_attributes = FactoryBot.attributes_for(:join_db)
        join_db_attributes[:user_id] = user.id
        join_db = JoinDb.create!(join_db_attributes)

        get join_db_url(join_db.id)
        expect(response).to redirect_to('/signup')
    end

    it "denies access if you're the wrong user" do
        user_attributes = FactoryBot.attributes_for(:user)
        user = User.create!(user_attributes)

        join_db_attributes = FactoryBot.attributes_for(:join_db)
        join_db_attributes[:user_id] = user.id
        join_db = JoinDb.create!(join_db_attributes)

        new_user_attributes = FactoryBot.attributes_for(:user)
        User.create!(new_user_attributes)

        post "/login", params: new_user_attributes

        get join_db_url(join_db.id)
        expect(response).to redirect_to('/')
    end

    it "succeeds if you're logged in and the right user" do
        user_attributes = FactoryBot.attributes_for(:user)
        user = User.create!(user_attributes)

        join_db_attributes = FactoryBot.attributes_for(:join_db)
        join_db_attributes[:user_id] = user.id
        join_db = JoinDb.create!(join_db_attributes)

        post "/login", params: user_attributes

        get join_db_url(join_db.id)
        expect(response).to have_http_status(200)
    end
end

describe "Creating a JoinDb", type: :request do
    it "denies access if you're not logged in" do
    end

    it "denies access if you're the wrong user" do
    end

    it "succeeds if you're logged in and the right user" do
    end

    it "is given a host and port on creation" do
    end
end

describe "Deleting a JoinDb", type: :request do
    it "deletes the JoinDB if you're the right user" do
    end

    it "fails if you're not logged in" do
    end

    it "fails if you're the wrong user" do
    end
end
