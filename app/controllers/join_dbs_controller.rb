class JoinDbsController < ApplicationController
    before_action :authorize
    before_action :set_join_db, only: [:show, :update, :edit, :destroy, :confirm_password_view]
    before_action :authorize_owner, only: [:show, :update, :edit, :destroy]
    before_action :confirm_join_db_password, only: [:update]
    before_action :show_notifications
    before_action :check_trial_joindb_limit, only: [:new, :create]

    # GET /joindb/:id
    def show
        # Session management so we don't have to keep asking them for their JoinDB password
        if session[:join_db_id] != params[:id].to_i
            session[:join_db_id] = params[:id]
            session[:join_db_password] = nil
        end

        @page_title = "Your JoinDb - #{JoinDb.find(params[:id]).name}"

        # Show RemoteDbs
        @remote_dbs = RemoteDb.where(join_db_id: params[:id])
        @new_rdb = RemoteDb.new
    end

    # GET /joindb/new
    def new
        @page_title = "New JoinDB"
        # Form for getting info to create the new JoinDb
        @user_id = current_user.id
        @join_db = JoinDb.new
    end

    # POST /joindb
    def create
        # Creates a new JoinDb
        @join_db = JoinDb.create(join_db_params.
            reject{|k, v| k == 'password' }.
            merge(user_id: current_user.id))
        @join_db.host = "provisioning..."
        if @join_db.save
            # Create the JoinDb
            Concurrent::Promise.execute { 
                @join_db.create_and_attach_cloud_db(
                    join_db_params[:username],
                    join_db_params[:password]
                )
            }.rescue do |reason|
                create_error_notification(
                    current_user.id,
                    "Error creating your JoinDb. Please try again in a
                    few minutes. Error was: #{reason}"
                )
                @join_db.destroy
            end
        else
            render :json => { :errors => @join_db.errors.full_messages }, :status => 422 and return
        end

        redirect_to @join_db
    end

    # UPDATE /join_dbs/:id
    def edit 
        @page_title = "Rename JoinDB"     
    end

    def update
        @join_db.update(join_db_params)
        redirect_to @join_db
    end

    # DELETE /joindb/:id
    def destroy
        @join_db.destroy
        redirect_to '/'
    end

    def confirm_password_view
    end

    def confirm_password
        @join_db = JoinDb.find(params[:join_db_id])
        @page_title = "Confirm Login for \"#{@join_db.name}\""
        begin
            open_connection(@join_db, params[:password])
            session[:join_db_id] = @join_db.id
            session[:join_db_password] = params[:password]
            redirect_to @join_db
        rescue Exception => e
            create_error_notification(
                current_user.id,
                "Could not verify your login: #{e}"
            )
            redirect_to confirm_join_db_password_path(@join_db)
        end
    end

    private
    def join_db_params
        params.require(:join_db).permit(:name, :user_id, :username, :password)
    end

    def set_join_db
        @join_db = JoinDb.find(params[:id])
    end

    def confirm_join_db_password
        redirect_to confirm_join_db_password_path(@join_db.id) and return if not (session[:join_db_password] and session[:join_db_id].to_i == @join_db.id)
    end

    def check_trial_joindb_limit
        # Limit trial users to 1 JoinDb
        if current_user.tier == "trial" and JoinDb.where(user_id: current_user.id).count > 0
            create_error_notification(
                current_user.id,
                "Please upgrade to create more than one JoinDB. Contact us at michael@getjoiner.com to upgrade!"
            )
            redirect_to '/' and return
        end
    end
end

