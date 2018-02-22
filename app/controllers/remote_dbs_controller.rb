class RemoteDbsController < ApplicationController
    before_action :authorize
    before_action :set_remote_db, only: [:show, :update, :edit, :destroy]    
    before_action :authorize_owner, only: [:show, :edit, :update, :destroy]
    before_action only: [:new] do
        authorize_owner(params[:join_db])
    end
    before_action only: [:create] do
        authorize_owner(remote_db_params[:join_db_id].to_i)
    end
    before_action :confirm_join_db_password, only: [:edit, :update, :destroy]
    before_action only: [:create] do
        confirm_join_db_password(remote_db_params[:join_db_id].to_i)
    end
    before_action :show_notifications, only: [:show, :edit, :new]

    def show
        # Show RemoteDb details
    end

    def new
        @page_title = "Add Connection"
        #authorize_owner(params[:join_db])
        # DB type constants
        @POSTGRES = "postgres"
        @MYSQL = "mysql"
        @SQLSERVER = "sql_server"
        @REDSHIFT = "redshift"

        # Form for getting info to create the new RemoteDb
        @join_db_id = params[:join_db].to_i
        confirm_join_db_password(@join_db_id)

        @join_db = JoinDb.find(@join_db_id)
        @remote_db = RemoteDb.new
    end

    def create
        rdb_params = remote_db_params

        # I might need this for tests to pass... probably best to fix the tests
        # rdb_params[:db_type] = remote_db_params[:db_type].to_i

        # Creates a new RemoteDb
        confirm_join_db_password(rdb_params[:join_db_id].to_i)

        if rdb_params[:csv]
            uploaded_file = rdb_params[:csv]
            File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
                file.write(uploaded_file.read)
            end

            rdb_params[:name] = uploaded_file.original_filename
            rdb_params[:filepath] = Rails.root.join(
                'public', 'uploads', uploaded_file.original_filename
            )

            # Default pgfutter schema; change if we stop using the default
            rdb_params[:schema] = 'import'
        end

        @remote_db = RemoteDb.create(rdb_params.reject{|k, v| k.include? "password" or k.include? "csv" })

        # Otherwise we're adding a database

        # Make sure we can actually create the FDW downstream       
        if @remote_db.save
            if create_remote_db(@remote_db, rdb_params[:password], session[:join_db_password]) 
                redirect_to join_db_path(rdb_params[:join_db_id]) and return
            else
                @remote_db.destroy
                render :json => { :errors => remote_db.errors.full_messages }, :status => 422 and return
            end
        else
            handle_error(
                @remote_db,
                "Could not create your Connection: 
                    #{@remote_db.errors.full_messages}"
            )
        end
    end

    # The edit UI for a RemoteDb
    def edit
        @join_db_id = @remote_db.join_db_id
        @join_db = JoinDb.find(@join_db_id)
    end
    
    # The PUT method to actually edit it
    def update
        join_db_id = @remote_db.join_db_id
        @remote_db.update!(remote_db_params.reject{|k, v| k.include? "password" })
        redirect_to join_db_path(join_db_id)
    end

    # Refreshes the mapping
    def refresh
        # Get the needed RemoteDb
        remote_db = RemoteDb.find(params[:id])
    
        # Confirm the user can edit/get their password
        confirm_join_db_password(remote_db.join_db_id)
        
        # Get the needed JoinDb it belongs to
        join_db = JoinDb.find(remote_db.join_db_id)
        
        # Refresh the mapping via joindb_api.rb
        Concurrent::Promise.execute{ 
            refresh_fdw(join_db, remote_db, session[:join_db_password])
        }.on_success{|res| create_success_notification(
            current_user.id, "Successfully refreshed connection!"
        )}.rescue{|reason| create_error_notification(
            current_user.id, "An error occurred while refreshing your connection."
        )}
    end

    def destroy
        join_db_id = @remote_db.join_db_id
        begin
            delete_fdw(@remote_db.join_db, @remote_db, session[:join_db_password])
            @remote_db.destroy
            redirect_to join_db_path(join_db_id)
        rescue
            handle_error(
                @remote_db,
                "Could not delete your connection:
                    #{@remote_db.errors.full_messages}"
            )
        end
    end

    private
    def remote_db_params
        params.require(:remote_db).permit(:name, :db_type, :host, :port, :database_name, :schema, :remote_user, :password, :join_db_id, :csv)
    end

    def set_remote_db
        @remote_db = RemoteDb.find(params[:id])
    end

    def create_remote_db(remote_db, remote_password, password)
        # Calls the API to add a FDW to the JoinDB
        join_db = remote_db.join_db
        promise = Concurrent::Promise.new do |_|
            if remote_db.postgres?
                add_fdw_postgres(join_db, remote_db, remote_password, password)
            elsif remote_db.mysql?
                add_fdw_mysql(join_db, remote_db, remote_password, password)
            elsif remote_db.sql_server?
                add_fdw_sql_server(join_db, remote_db, remote_password, password)
            elsif remote_db.redshift?
                add_fdw_postgres(join_db, remote_db, remote_password, password)
            elsif remote_db.csv?
                add_csv(join_db, remote_db, password)
            else
                return false
            end
        end
        promise.execute.rescue{|reason| create_error_notification(
            current_user.id,
            "Error creating your Connection. Error was: #{reason}"
        )}
    end

    def handle_error(remote_db, message)
        create_error_notification(
            current_user.id,
            message
        )
        redirect_to join_db_path(remote_db.join_db_id)
    end

    def confirm_join_db_password(join_db_id = nil)
        join_db_id ||= @remote_db.join_db_id

        redirect_to confirm_join_db_password_path(join_db_id) and return if not (session[:join_db_password] and session[:join_db_id].to_i == join_db_id)
    end
end
