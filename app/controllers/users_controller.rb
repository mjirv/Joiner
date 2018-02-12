# app/controllers/users_controller.rb

class UsersController < ApplicationController
    before_action :authorize, only: [:show]
    before_action :show_notifications, only: [:show]

    def new
        @page_title = "Sign Up"
    end

    def create
        user = User.new(user_params)
        if user.save
            Concurrent::Future.execute{ 
                ApplicationMailer.registration_confirmation(user).deliver
            }
            flash[:success] = "Please check your email and confirm your
                email address to continue."
            redirect_to '/login'
        else
            flash[:notice] = "Could not create your user."
            redirect_to '/signup'
        end
    end

    def show
        @page_title = "Your JoinDBs"
        @join_dbs = JoinDb.where(user_id: session[:user_id])
    end

    def confirm_email
        user = User.find_by_confirm_token(params[:id])
        if user
            user.email_activate
            flash[:success] = "Welcome to Joiner. Your email has been confirmed!"
            session[:user_id] = user.id
            redirect_to '/'
        else
            flash[:notice] = "Sorry, that user does not exist."
            redirect_to '/'
        end
    end

    private
    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end