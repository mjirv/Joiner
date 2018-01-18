class RemoteDbsController < ApplicationController
    include JoindbClientMethods
    before_action :authorize
    before_action :set_remote_db, only: [:show, :update, :edit, :destroy]    
    before_action :authorize_owner, only: [:show, :edit, :update, :destroy]

    def show
        # Show RemoteDb details
    end

    def new
        authorize_owner(params[:join_db])
        # DB type constants
        @POSTGRES = 0
        @MYSQL = 1

        # Form for getting info to create the new RemoteDb
        @join_db_id = params[:join_db]
        @remote_db = RemoteDb.new
    end

    def create
        # Creates a new RemoteDb
        authorize_owner(remote_db_params[:join_db_id])

        @remote_db = RemoteDb.create(remote_db_params.reject{|k, v| k == "password"})

        # Make sure we can actually create the FDW downstream       
        if @remote_db.save
            if create_remote_db(@remote_db, remote_db_params[:password]) 
                redirect_to join_db_path(remote_db_params[:join_db_id]) and return
            else
                @remote_db.delete
                render :json => {:status => 422}
            end
        else
            render :json => { :errors => @remote_db.errors.full_messages }, :status => 422
        end
    end

    # UPDATE /remote_dbs/:id
    def edit
        @join_db_id = @remote_db.join_db_id
    end
    
    def update
        join_db_id = @remote_db.join_db_id
        @remote_db.update!(remote_db_params.reject{|k, v| k == "password"})
        redirect_to join_db_path(join_db_id)
    end

    def destroy
        join_db_id = @remote_db.join_db_id
        @remote_db.delete
        redirect_to join_db_path(join_db_id)
    end

    private
    def remote_db_params
        params.require(:remote_db).permit(:name, :db_type, :host, :port, :database_name, :schema, :remote_user, :password, :join_db_id)
    end

    def set_remote_db
        @remote_db = RemoteDb.find(params[:id])
    end

    def create_remote_db(remote_db, password)
        join_db = remote_db.join_db
        if remote_db.postgres?
            add_fdw_postgres(join_db, remote_db, password)
        elsif remote_db.mysql?
            add_fdw_mysql(join_db, remote_db, password)
        else
            return false
        end
    end
end

