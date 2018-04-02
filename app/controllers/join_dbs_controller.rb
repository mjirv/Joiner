class JoinDbsController < ApplicationController
    before_action :authorize
    before_action :set_join_db, only: [:show, :update, :edit, :destroy, :confirm_password_view, :show_connections, :show_mappings]
    before_action :authorize_owner, only: [:show, :update, :edit, :destroy, :show_connections, :show_mappings]
    before_action :show_notifications
    before_action :check_trial_joindb_limit, only: [:new, :create]
    before_action only: [:show, :update, :show_connections, :show_mappings] do
        join_db_id = params[:id].to_i
        if not JoinDb.find(join_db_id).provisioning?
            confirm_join_db_password(join_db_id)
        end
    end

    # Overview page for single JoinDb
    def show
        # Session management so we don't have to keep asking them for their JoinDB password
        if session[:join_db_id] != params[:id].to_i
            session[:join_db_id] = params[:id]
            session[:join_db_password] = nil
        end

        @page_title = "Your Warehouse: #{JoinDb.find(params[:id]).name}"

        # Show RemoteDbs
        @remote_dbs = RemoteDb.where(
            join_db_id: params[:id],
            status: [RemoteDb.statuses[:enabled],
                RemoteDb.statuses[:provisioning]]
        )
        @new_rdb = RemoteDb.new
    end

    # Shows info about a JoinDb's connections
    def show_connections
        @page_title = "Your Warehouse: #{JoinDb.find(params[:id]).name}"

        # Show RemoteDbs
        @remote_dbs = RemoteDb.where(
            join_db_id: params[:id],
            status: [RemoteDb.statuses[:enabled],
                RemoteDb.statuses[:provisioning]]
        )
        @new_rdb = RemoteDb.new
    end

    def show_mappings
        @page_title = "Your Warehouse: #{JoinDb.find(params[:id]).name}"

        # Show RemoteDbs
        @remote_dbs = RemoteDb.where(
            join_db_id: params[:id],
            status: [RemoteDb.statuses[:enabled],
                RemoteDb.statuses[:provisioning]]
        )
    end

    # GET /joindb/new
    def new
        @page_title = "New Warehouse"
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
        @join_db.status = JoinDb.statuses[:provisioning]

        if @join_db.save
            # Create the JoinDb
            Concurrent::Promise.execute { 
                @join_db.create_and_attach_cloud_db(
                    join_db_params[:username],
                    join_db_params[:password]
                )
            }.on_success{|_|
                @join_db.status = JoinDb.statuses[:enabled]
                @join_db.save
            }.
            rescue do |reason|
                create_error_notification(
                    current_user.id,
                    "Error creating your Warehouse. Please try again in a
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
        @page_title = "Rename Warehouse"     
    end

    def update
        @join_db.update(join_db_params)
        redirect_to @join_db
    end

    # DELETE /joindb/:id
    def destroy
        @join_db.disable
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

    def check_trial_joindb_limit
        # Limit most users to 1 JoinDb
        if ["individual", "team"].include? current_user.tier and JoinDb.where(
            user_id: current_user.id,
            status: JoinDb.statuses[:enabled]
        ).count > 0
            create_error_notification(
                current_user.id,
                "Please upgrade to create more than one JoinDB. Contact us at michael@getjoiner.com to upgrade!"
            )
            redirect_to '/' and return
        end
    end
end

