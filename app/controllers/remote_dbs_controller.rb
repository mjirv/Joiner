class RemoteDbsController < ApplicationController
    include JoindbClientMethods
    before_action :authorize
    before_action :set_remote_db, only: [:show, :update, :edit, :destroy]    

    def show
        # Show RemoteDb details
        @remote_db = RemoteDb.find(params[:id])
    end

    def new
        # DB type constants
        @POSTGRES = 0
        @MYSQL = 1

        # Form for getting info to create the new RemoteDb
        @join_db_id = params[:join_db]
        @remote_db = RemoteDb.new
    end

    def create
        # Creates a new RemoteDb
        @remote_db = RemoteDb.create!(remote_db_params.reject{|k, v| k == "password"})
        redirect_to join_db_path(remote_db_params[:join_db_id])
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
end

