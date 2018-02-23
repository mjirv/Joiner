require 'rails_helper'

TESTFILE = "test_good.csv"
BAD_TESTFILE = "test_bad.csv"

#FactoryBot.find_definitions

describe RemoteDb do

    before(:all) do 
        @user_attributes = FactoryBot.attributes_for(:user)
        @wrong_user_attributes = FactoryBot.attributes_for(:user)
        @join_db_attributes = FactoryBot.attributes_for(:join_db)
        
        user = User.create!(@user_attributes)
        user.email_confirmed = true
        user.tier = "paid"
        user.save!

        wrong_user = User.create!(@wrong_user_attributes)
        wrong_user.email_confirmed = true
        wrong_user.tier = "paid"
        wrong_user.save!

        @join_db_attributes[:user_id] = user.id
        @join_db = JoinDb.create!(
            @join_db_attributes.reject{|k, v| k == :password}
        )
        @join_db.create_and_attach_cloud_db(
            @join_db_attributes[:username],
            @join_db_attributes[:password]
        )
    end

    after(:all) do
        #@join_db.destroy!
        #JoinDb.where("host LIKE '%amazonaws%'").map(&:destroy)
        #JoinDb.destroy_all
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
            expect(response).to have_http_status(200)
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

        ["postgres", "redshift"].each do |needs_schema_type|
            it "fails if #{needs_schema_type} and you don't include a schema" do
                @remote_db_attributes[:db_type] = needs_schema_type
                post '/login', params: @user_attributes
                post '/confirm_join_db_password', 
                    params: {
                        join_db_id: @join_db.id,
                        password: @join_db_attributes[:password]
                    }
                post '/remote_dbs', params: {
                    remote_db: @remote_db_attributes.reject{|k, v| k == :schema}
                }
                expect(response).to redirect_to join_db_path(@join_db.id)

                # It should create a notification too
                expect(Notification.where(
                    user_id: @join_db.user_id,
                    status: "enabled"
                ).count).to eq(1)
            end
        end

        it "fails without a hostname" do 
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: @remote_db_attributes.reject{|k, v| k == :host}
            }
            expect(response).to redirect_to join_db_path(@join_db.id)

            # It should create a notification too
            expect(Notification.where(
                user_id: @join_db.user_id,
                status: "enabled"
            ).count).to eq(1)
        end

        it "fails without a port" do
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: @remote_db_attributes.reject{|k, v| k == :port}
            }
            expect(response).to redirect_to join_db_path(@join_db.id)

            # It should create a notification too
            expect(Notification.where(
                user_id: @join_db.user_id,
                status: "enabled"
            ).count).to eq(1)
        end

        it "fails without a db type" do 
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: @remote_db_attributes.reject{|k, v| k == :db_type}
            }
            expect(response).to redirect_to join_db_path(@join_db.id)

            # It should create a notification too
            expect(Notification.where(
                user_id: @join_db.user_id,
                status: "enabled"
            ).count).to eq(1)
        end

        it "fails without a database name" do 
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: @remote_db_attributes.reject{
                    |k, v| k == :database_name
                }
            }
            expect(response).to redirect_to join_db_path(@join_db.id)

            # It should create a notification too
            expect(Notification.where(
                user_id: @join_db.user_id,
                status: "enabled"
            ).count).to eq(1)
        end

        it "fails without a remote username" do
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: @remote_db_attributes.reject{|k, v| k == :remote_user}
            }
            expect(response).to redirect_to join_db_path(@join_db.id)

            # It should create a notification too
            expect(Notification.where(
                user_id: @join_db.user_id,
                status: "enabled"
            ).count).to eq(1)
        end

        it "exists with the right fields on successful creation" do
            @remote_db_attributes = {
                host: 'mysql-rfam-public.ebi.ac.uk',
                port: 4497,
                remote_user: 'rfamro',
                password: '',
                database_name: 'Rfam',
                db_type: 'mysql',
                join_db_id: @join_db.id
            }
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: @remote_db_attributes
            }
            expect(response).to redirect_to join_db_url(@join_db.id)
            remote_db = @join_db.remote_dbs.last
            expect(remote_db.host).to eq(@remote_db_attributes[:host])
        end
    end

    describe "CSV RemoteDbs", type: :request do
        it "creates the RemoteDb if it's a valid CSV" do 
            @csv_remote_db_attributes = {
                csv: File.open(Rails.root.join('public', 'test', TESTFILE)),
                join_db_id: @join_db.id
            }
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: @csv_remote_db_attributes
            }

            expect(response).to redirect_to join_db_url(@join_db.id)
            remote_db = @join_db.remote_dbs.last

            # Change this if we stop using the default pgfutter schema
            expect(remote_db.schema).to_eq 'import'
        end
        it "fails if it's not a CSV" do 
            csv_remote_db_attributes = {
                csv: File.open(Rails.root.join('public', 'test', BAD_TESTFILE)),
                join_db_id: @join_db.id
            }
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: csv_remote_db_attributes
            }

            expect(response).to redirect_to join_db_path(@join_db.id)

            # It should create a notification too
            expect(Notification.where(
                user_id: @join_db.user_id,
                status: "enabled"
            ).count).to eq(1)
        end
        it "deletes the CSV if you're logged in and the right user" do 
            csv_id = RemoteDb.where(
                join_db_id: @join_db.id, 
                db_type: 'csv'
            ).last.id

            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }

            get delete_remote_db_url(csv_id)
            expect(response).to redirect_to join_db_url(@join_db.id)
            expect(RemoteDb.where(
                join_db_id: @join_db.id, 
                db_type: 'csv'
            ).count).to eq(0)
        end
    end

    describe "Deleting a RemoteDb", type: :request do
        it "deletes the RemoteDb if you're logged in and the right user" do
            @remote_db_attributes = {
                host: 'mysql-rfam-public.ebi.ac.uk',
                port: 4497,
                remote_user: 'rfamro',
                password: '',
                database_name: 'Rfam',
                db_type: 'mysql',
                join_db_id: @join_db.id
            }
            post '/login', params: @user_attributes
            post '/confirm_join_db_password', 
                params: {
                    join_db_id: @join_db.id,
                    password: @join_db_attributes[:password]
                }
            post '/remote_dbs', params: {
                remote_db: @remote_db_attributes
            }

            sleep(240)

            remote_db = @join_db.remote_dbs.last
            get delete_remote_db_url(remote_db.id)
            expect(response).to redirect_to join_db_url(@join_db.id)
        end

        it "fails if you're not logged in" do 
            get delete_remote_db_url(@remote_db.id)
            expect(response).to redirect_to '/signup'
        end

        it "fails if you're the wrong user" do
            post '/login', params: @wrong_user_attributes
            get delete_remote_db_url(@remote_db.id)
            expect(response).to redirect_to '/'
        end
    end
end