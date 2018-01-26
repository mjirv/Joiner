# app/controllers/users_controller.rb

class UsersController < ApplicationController
    before_action :authorize, only: [:show]

    def new
    end

    def create
        user = User.new(user_params)
        if user.save
            session[:user_id] = user.id
            redirect_to '/'
        else
            redirect_to '/signup'
        end
    end

    def show
        @join_dbs = JoinDb.where(user_id: session[:user_id])
    end

    private
    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end