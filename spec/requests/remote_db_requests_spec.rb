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
        @remote_db_attributes_for_creation = @remote_db_attributes.reject{|k, v| k == :password}
        @remote_db = RemoteDb.create!(@remote_db_attributes_for_creation)
    end

    describe "Viewing the create page for a RemoteDb", type: :request do
        it "denies access if you're not logged in" do
            get remote_dbs_new_url, params: {join_db: @join_db.id}
            expect(response).to redirect_to '/signup'
        end

        it "denies access if you're the wrong user" do
            post '/login', params: @wrong_user_attributes
            get remote_dbs_new_url, params: {join_db: @join_db.id}
            expect(response).to redirect_to '/'
        end

        it "redirects you to confirm if you're logged in and the right user, but haven't confirmed your JoinDb credentials" do
            post '/login', params: @user_attributes
            get remote_dbs_new_url, params: {join_db: @join_db.id}
            expect(response).to redirect_to confirm_join_db_password_url(@join_db.id)
        end

        it "succeeds if you're logged in, the right user, and confirmed" do
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            get remote_dbs_new_url, params: {join_db: @join_db.id}
            expect(response).to redirect_to confirm_join_db_password_url(@join_db.id)
        end
    end

    describe "Creating a RemoteDb", type: :request do
        it "denies access if you're not logged in" do
            post '/remote_dbs', params: {remote_db: @remote_db_attributes}
            expect(response).to redirect_to '/signup'
        end

        it "denies access if you're the wrong user" do
            post '/login', params: @wrong_user_attributes
            post '/remote_dbs', params: {remote_db: @remote_db_attributes}
            expect(response).to redirect_to '/'
        end

        it "redirects you to confirm if you're logged in and the right user, but haven't confirmed your JoinDb credentials" do
            post '/login', params: @user_attributes
            post '/remote_dbs', params: {remote_db: @remote_db_attributes}
            expect(response).to redirect_to confirm_join_db_password_url(@join_db.id)
        end

        it "succeeds if you're logged in, the right user, and confirmed" do
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {remote_db: @remote_db_attributes}
                expect(response).to redirect_to confirm_join_db_password_url(@join_db.id)
        end

        it "fails if postgres and you don't include a schema"

        it "fails without a hostname"

        it "fails without a port"

        it "fails without a db type"

        it "fails without a database name"

        it "fails without a remote username"

        it "exists with the right fields on creation"
    end

    describe "Deleting a RemoteDb", type: :request do
        it "deletes the JoinDB if you're logged in and the right user"

        it "fails if you're not logged in"

        it "fails if you're the wrong user"
    end
end