require 'rails_helper'

FactoryBot.find_definitions

describe "Public access to User Dashboard", type: :request do
    it "denies access to users#show" do
        get '/'
        expect(response).to redirect_to '/signup'
    end

    it "allows access to users#show when signed in" do
        user_attributes = FactoryBot.attributes_for(:user)
        User.create!(user_attributes)
        post "/login", params: user_attributes 
        expect(response).to redirect_to "/"
    end

end

describe "Viewing a JoinDb", type: :request do
    it "denies access if you're not logged in" do
    end

    it "denies access if you're the wrong user" do
    end

    it "succeeds if you're logged in and the right user" do
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