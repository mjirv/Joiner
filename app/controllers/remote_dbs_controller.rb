class RemoteDbsController < ApplicationController
    before_action :authorize
    before_action :set_remote_db, only: [:show, :update, :edit, :destroy]    
    before_action :authorize_owner, only: [:show, :edit, :update, :destroy]
    before_action :confirm_join_db_password, only: [:edit, :update, :destroy]

    def show
        # Show RemoteDb details
    end

    def new
        authorize_owner(params[:join_db])
        # DB type constants
        @POSTGRES = "postgres"
        @MYSQL = "mysql"

        # Form for getting info to create the new RemoteDb
        @join_db_id = params[:join_db].to_i
        confirm_join_db_password(@join_db_id)

        @join_db = JoinDb.find(@join_db_id)
        @remote_db = RemoteDb.new
    end

    def create
        params[:db_type] = params[:db_type].to_i
        # Creates a new RemoteDb
        authorize_owner(remote_db_params[:join_db_id].to_i)
        confirm_join_db_password(remote_db_params[:join_db_id].to_i)

        @remote_db = RemoteDb.create(remote_db_params.reject{|k, v| k.include? "password" })

        # Make sure we can actually create the FDW downstream       
        if @remote_db.save
            if create_remote_db(@remote_db, remote_db_params[:password], session[:join_db_password]) 
                redirect_to join_db_path(remote_db_params[:join_db_id]) and return
            else
                @remote_db.delete
                render :json => {:status => 422} and return
            end
        else
            handle_error(@remote_db)
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
        refresh_fdw(join_db, remote_db, session[:join_db_password])
    end

    def destroy
        join_db_id = @remote_db.join_db_id
        if delete_fdw(@remote_db.join_db, @remote_db, session[:join_db_password])
            @remote_db.delete
            redirect_to join_db_path(join_db_id)
        else
            handle_error(@remote_db)
        end
    end

    private
    def remote_db_params
        params.require(:remote_db).permit(:name, :db_type, :host, :port, :database_name, :schema, :remote_user, :password, :join_db_id)
    end

    def set_remote_db
        @remote_db = RemoteDb.find(params[:id])
    end

    def create_remote_db(remote_db, remote_password, password)
        # Calls the API to add a FDW to the JoinDB
        join_db = remote_db.join_db
        if remote_db.postgres?
            add_fdw_postgres(join_db, remote_db, remote_password, password)
        elsif remote_db.mysql?
            add_fdw_mysql(join_db, remote_db, remote_password, password)
        else
            return false
        end
    end

    def handle_error(remote_db)
        render :json => { :errors => remote_db.errors.full_messages }, :status => 422        
    end

    def confirm_join_db_password(join_db_id = nil)
        join_db_id ||= @remote_db.join_db_id

        redirect_to confirm_join_db_password_path(join_db_id) and return if not (session[:join_db_password] and session[:join_db_id].to_i == join_db_id)
    end
end

