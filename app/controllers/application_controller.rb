class ApplicationController < ActionController::Base
    include JoindbApi
    protect_from_forgery with: :null_session

    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user
    
    def authorize
        redirect_to '/login' unless current_user
    end

    def authorize_owner(join_db_id=nil)
        join_db_id ||= @remote_db.join_db_id rescue @join_db.id
        redirect_to '/' unless JoinDb.find(join_db_id).user_id == current_user.id
    end
end
