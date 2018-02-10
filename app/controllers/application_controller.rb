class ApplicationController < ActionController::Base
    include JoindbApi
    protect_from_forgery with: :null_session

    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user
    
    def authorize
        flash[:notice] = "You are not logged in. Please log in or sign up!"
        redirect_to '/signup' and return unless current_user
    end

    def authorize_owner(join_db_id=nil)
        join_db_id ||= @remote_db.join_db_id rescue @join_db.id
        
        if JoinDb.find(join_db_id).user_id == current_user.id
            return true
        else
            create_error_notification(
                current_user.id,
                "Hey, that JoinDb doesn't belong to you! (Or we couldn't connect,
                so try again in a few minutes.)"
            )
            redirect_to '/'
        end
    end

    def get_notifications
        @notifications = Notification.where(user_id: current_user.id, status: Notification.statuses[:enabled])
    end

    def show_notifications
        notifications = get_notifications()
        if notifications.length > 0
            flash[:notice] = notifications.map(&:message).join("\n")
            notifications.map do |n|
                n.status = Notification.statuses[:disabled]
                n.save
            end
        else
            flash[:notice] = nil
        end
    end
    helper_method :show_notifications

    def create_notification(user_id, message, type)
        n = Notification.create!(user_id: user_id, message: message, notification_type: type, status: Notification.statuses[:enabled])
    end

    def create_error_notification(user_id, message)
        create_notification(user_id, message, Notification.notification_types[:error])
    end

    def create_success_notification(user_id, message)
        create_notification(user_id, message, Notification.notification_types[:success])
    end
end
