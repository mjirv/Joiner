# app/controllers/sessions_controller.rb

class SessionsController < ApplicationController
    
    def new
    end

    def create
        user = User.find_by_email(params[:email])
        # If the user exists AND the password entered is correct.
        if user && user.authenticate(params[:password])
            if user.email_confirmed
                # Save the user id inside the browser cookie. This is how we keep the user 
                # logged in when they navigate around our website.
                session[:user_id] = user.id
                redirect_to '/'
            else
                flash[:notice] = "Please check your email to confirm your account."
                redirect_to '/login'
            end
        else
        # If user's login doesn't work, send them back to the login form.
            flash[:notice] = "Invalid login credentials. Please try again!"
            redirect_to '/login'
        end
    end
    
    def destroy
        session[:user_id] = nil
        redirect_to '/login'
    end
    
end