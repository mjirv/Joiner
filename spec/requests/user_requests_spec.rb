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
        user_attributes[:email_confirmed] = true
        User.create!(user_attributes)
        post "/login", params: user_attributes 
        expect(response).to redirect_to "/"
    end

    it "successfully loads the login page" do
        get "/login"
        expect(response).to have_http_status(200)
    end
end

describe "Logging in", type: :request do
    it "denies access if you give bad credentials" do
        fake_user_attributes = FactoryBot.attributes_for(:user)
        post "/login", params: fake_user_attributes
        expect(response).to redirect_to "/login"
    end

    it "does not let you log in if you haven't confirmed your email" do
        user_attributes = FactoryBot.attributes_for(:user)
        post '/users', params: {user: user_attributes}
        post '/login', params: user_attributes
        expect(response).to redirect_to '/login'
    end

    it "lets you log in if you have confirmed your email" do
        user_attributes = FactoryBot.attributes_for(:user)
        post '/users', params: {user: user_attributes}
        user = User.last
        get confirm_email_user_path(user.confirm_token)
        post '/login', params: user_attributes
        expect(response).to redirect_to '/'
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
        expect(response).to redirect_to "/login"
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

    it "successfully loads the signup page" do
        get "/signup"
        expect(response).to have_http_status(200)
    end
end
