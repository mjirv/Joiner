require 'rails_helper'

#FactoryBot.find_definitions

describe RemoteDb do

    before(:all) do 
        @user_attributes = FactoryBot.attributes_for(:user)
        @wrong_user_attributes = FactoryBot.attributes_for(:user)
        @join_db_attributes = FactoryBot.attributes_for(:join_db)
        
        user = User.create!(@user_attributes)
        wrong_user = User.create!(@wrong_user_attributes)

        @join_db_attributes[:user_id] = user.id
        @join_db = JoinDb.create!(
            @join_db_attributes.reject{|k, v| k == :password}
        )
    end

    before(:each) do 
        @remote_db_attributes = FactoryBot.attributes_for(:remote_db)
        @remote_db_attributes[:join_db_id] = @join_db.id
        @remote_db = RemoteDb.create!(@remote_db_attributes)
    end

    describe "Viewing the edit page for a RemoteDb", type: :request do
        it "denies access if you're not logged in" do
            get edit_remote_db_url(@remote_db.id)
            expect(response).to redirect_to '/signup'
        end

        it "denies access if you're the wrong user" do
            post '/login', params: @wrong_user_attributes
            get edit_remote_db_url(@remote_db.id)
            expect(response).to redirect_to '/'
        end

        it "redirects you to confirm if you're logged in and the right user, but haven't confirmed your JoinDb credentials" do
            post '/login', params: @user_attributes
            get edit_remote_db_url(@remote_db.id)
            expect(response).to redirect_to confirm_join_db_password_url(@join_db.id)
        end

        it "succeeds if you're logged in, the right user, and confirmed" do
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            get edit_remote_db_url(@remote_db.id)
            expect(response).to redirect_to confirm_join_db_password_url(@join_db.id)
        end
    end

    describe "Editing a RemoteDb", type: :request do

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