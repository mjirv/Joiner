# app/controllers/users_controller.rb

class UsersController < ApplicationController
    before_action :authorize, only: [:show, :update, :reset_password]
    before_action :show_notifications, only: [:show]

    def new
        @page_title = "Sign Up"
    end

    def create
        user = User.new(user_params)

        # Temporary code to limit the number of beta users
        if User.count >= ENV['BETA_USER_LIMIT'].to_i
            limit_beta(user)
            flash[:success] = "Thanks for signing up! Our closed beta is full right now, but we've added you to the wait list and will let you know as soon as a spot opens up. Please contact michael@getjoiner.com with any questions!"
            redirect_to '/login'
            return
        end

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

    def update
        @user = User.find(params[:id])
        if @user.update(user_params)
            # If they're resetting their password, get rid of the token
            @user.reload()
            if @user.reset_token
                @user.reset_token = nil
                @user.save!
            end
            flash[:success] = "Successfully updated your account"
            redirect_to '/'
        else
            flash[:notice] = "An error occurred, please try again: #{@user.errors.full_messages}"
            redirect_to reset_password_path(@user.reset_token)
        end
    end

    def show
        @page_title = "Your Warehouses"
        @join_dbs = JoinDb.where(
            user_id: session[:user_id],
            status: JoinDb.statuses[:enabled]
        )
    end

    def confirm_email
        @user = User.find_by_confirm_token(confirm_params)
        if @user
            @user.email_activate()
            # TODO: Change this or get rid of in-app signup
            flash[:success] = "Welcome to Joiner! Your email has been confirmed. Please reset your password."
            session[:user_id] = @user.id
            redirect_to reset_password_path(@user.reset_token)
        else
            if current_user and current_user.reset_token
                flash[:success] = "Welcome to Joiner! Your email has been confirmed. Please reset your password."
                session[:user_id] = current_user.id
                redirect_to reset_password_path(current_user.reset_token)
            elsif current_user
                flash[:notice] = "Looks like you've already confirmed!"
                redirect_to '/'
            else
                flash[:notice] = "Sorry, that user does not exist."
                redirect_to '/signup'
            end
        end
    end

    def reset_password
        @user = User.find_by_reset_token(confirm_params)
        @page_title = "Reset your password"
    end

    def destroy
        user = User.find(params[:id])
        user.disable
        session[:user_id] = nil
        redirect_to '/signup'
    end

    private
    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def confirm_params
        params.require("token")
    end

    def limit_beta(user)
        Concurrent::Future.execute{ 
            ApplicationMailer.beta_signup(user).deliver
        }
    end
end