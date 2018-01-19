class JoinDbsController < ApplicationController
    include JoindbClientMethods
    before_action :authorize
    before_action :set_join_db, only: [:show, :update, :edit, :destroy, :confirm_password_view]
    before_action :authorize_owner, only: [:show, :update, :edit, :destroy]

    # GET /joindb/:id
    def show
        # Session management so we don't have to keep asking them for their JoinDB password
        if session[:join_db_id] != params[:id].to_i
            session[:join_db_id] = params[:id]
            session[:join_db_password] = nil
        end

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
        @join_db = JoinDb.create!(join_db_params.
            reject{|k, v| [:password, :username].include? k }.
            merge(user_id: current_user.id))
        add_user(join_db_params[:username], join_db_params[:password], @join_db)
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

    def confirm_password_view
    end

    def confirm_password
        @join_db = JoinDb.find(params[:join_db_id])
        if true #open_connection(@join_db, params[:password])
            # TODO: change this when not testing
            session[:join_db_id] = @join_db.id
            session[:join_db_password] = params[:password]
            redirect_to @join_db
        else
            redirect_to confirm_join_db_password(@join_db)
        end
    end

    private
    def join_db_params
        params.require(:join_db).permit(:name, :user_id, :username, :password)
    end

    def set_join_db
        @join_db = JoinDb.find(params[:id])
    end
end

