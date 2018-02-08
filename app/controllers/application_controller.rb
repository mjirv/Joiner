class ApplicationController < ActionController::Base
    include JoindbApi
    protect_from_forgery with: :null_session

    class Notifier
        def update(time, value, reason)
            flash[:notice] = "#{value} | #{reason}"
        end
    end

    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user
    
    def authorize
        redirect_to '/signup' and return unless current_user
    end

    def authorize_owner(join_db_id=nil)
        join_db_id ||= @remote_db.join_db_id rescue @join_db.id
        
        if JoinDb.find(join_db_id).user_id == current_user.id
            return true
        else
            redirect_to '/'
        end
    end
end
