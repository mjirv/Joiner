require 'rails_helper'

# TODO: We shouldn't need this, but it can't find user otherwise
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
        fake_user_attributes = FactoryBot.attributes_for(:user)
        post "/login", params: fake_user_attributes
        expect(response).to redirect_to "/login"
    end
end

describe "Signing up", type: :request do
    it "denies signup without a valid email" do
        user_attributes = FactoryBot.attributes_for(:user)
        user_attributes[:email] = "michael.irvine"
        post "/users", params: {user: user_attributes}
        expect(response).to redirect_to "/signup"
    end

    it "approves signup with a valid email" do
        user_attributes = FactoryBot.attributes_for(:user)
        post "/users", params: {user: user_attributes}
        expect(response).to redirect_to "/"
    end

    it "denies signup without a unique email" do
        user_attributes = FactoryBot.attributes_for(:user)
        User.create!(user_attributes)
        user_attributes[:name] = "FakeName" # So the name is unique
        post "/users", params: {user: user_attributes}
        expect(response).to redirect_to "/signup"
    end

    it "denies signup without a unique name" do
        user_attributes = FactoryBot.attributes_for(:user)
        User.create!(user_attributes)
        user_attributes[:email] = "michael.irvine@gmail.com" # So the email is unique
        post "/users", params: {user: user_attributes}
        expect(response).to redirect_to "/signup"
    end
end

describe "Deleting a user", type: :request do
    it "deletes the user's JoinDb" do
        # TODO: This should probably be under the model
    end

    it "deletes the user's JoinDB" do
    end
end