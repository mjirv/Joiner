class JoinDbsController < ApplicationController
    include JoindbClientMethods
    before_action :authorize
    before_action :set_join_db, only: [:show, :update, :edit, :destroy]
    before_action :authorize_owner, only: [:show, :update, :edit, :destroy]

    # GET /joindb/:id
    def show
        # Show RemoteDbs
        @remote_dbs = RemoteDb.where(join_db_id: params[:id])
    end

    # GET /joindb/new
    def new
        # Form for getting info to create the new JoinDb
        @user_id = current_user.id
        @join_db = JoinDb.new
    end

    # POST /joindb
    def create
        # Creates a new JoinDb
        @join_db = JoinDb.create!(join_db_params.merge(user_id: current_user.id))
        redirect_to @join_db
    end

    # UPDATE /join_dbs/:id
    def edit      
    end

    def update
        @join_db.update(join_db_params)
        redirect_to @join_db
    end

    # DELETE /joindb/:id
    def destroy
        @join_db.delete
        redirect_to '/'
    end

    private
    def join_db_params
        params.require(:join_db).permit(:name, :user_id)
    end

    def set_join_db
        @join_db = JoinDb.find(params[:id])
    end
end

