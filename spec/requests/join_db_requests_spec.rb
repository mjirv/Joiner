require 'rails_helper'

#FactoryBot.find_definitions

describe JoinDb do
    before(:all) do
        @user_attributes = FactoryBot.attributes_for(:user)
        @user = User.create!(@user_attributes)
    end

    before(:each) do
        @join_db_attributes = FactoryBot.attributes_for(:join_db)
        @join_db_attributes[:user_id] = @user.id
        @join_db = JoinDb.create!(
            @join_db_attributes.reject {|k, v| k == :password}
        )
    end

    describe "Viewing a JoinDb", type: :request do
        it "denies access if you're not logged in" do
            get join_db_url(@join_db.id)
            expect(response).to redirect_to('/signup')
        end

        it "denies access if you're the wrong user" do
            new_user_attributes = FactoryBot.attributes_for(:user)
            User.create!(new_user_attributes)

            post "/login", params: new_user_attributes

            get join_db_url(@join_db.id)
            expect(response).to redirect_to('/')
        end

        it "succeeds if you're logged in and the right user" do
            post "/login", params: @user_attributes

            get join_db_url(@join_db.id)
            expect(response).to have_http_status(200)
        end
    end

    describe "Creating a JoinDb", type: :request do
        it "denies access if you're not logged in" do
            post '/join_dbs', params: @join_db_attributes
            expect(response).to redirect_to('/signup')
        end

        # Don't have a test for if you're the wrong user, because it just assigns it to you

        it "succeeds if you're logged in and the right user" do
            post "/login", params: @user_attributes
            post "/join_dbs", params: {join_db: @join_db_attributes}
            expect(response).to have_http_status(302)

            join_db = JoinDb.where(user_id: @user.id).last
            expect(join_db.host).not_to be_nil
            expect(join_db.port).not_to be_nil

            # We don't want to keep adding to my AWS bill
            join_db.destroy
        end

        it "fails if you don't give it a name" do
            join_db_attributes = @join_db_attributes.
                except(:name)

            post "/login", params: @user_attributes
            post "/join_dbs", params: {join_db: join_db_attributes}
            expect(response).to have_http_status(422)
        end

        it "is given a host and port on creation" do
            post "/login", params: @user_attributes
            post "/join_dbs", params: {join_db: @join_db_attributes}
        end
    end

    describe "Deleting a JoinDb", type: :request do
        it "deletes the JoinDB if you're the right user" do
            post '/login', params: @user_attributes
            get delete_join_db_url(@join_db.id)
            expect(response).to redirect_to('/')
            expect(JoinDb.where(user_id: @user.id).count).to eq(0)
        end

        it "fails if you're not logged in" do
            get delete_join_db_url(@join_db.id)
            expect(response).to redirect_to('/signup')
        end

        it "fails if you're the wrong user" do
            new_user_attributes = FactoryBot.attributes_for(:user)
            new_user = User.create!(new_user_attributes)

            post '/login', params: new_user_attributes
            get delete_join_db_url(@join_db.id)
            expect(response).to redirect_to '/'
        end
    end
end