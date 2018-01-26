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

describe "Logging in", type: :request do
    it "denies access if you give bad credentials" do
    end
end

describe "Signing up", type: :request do
    it "denies signup without a valid email" do
    end

    it "approves signup with a valid email" do
    end

    it "denies signup without a unique email" do
    end

    it "denies signup without a unique password" do
    end
end