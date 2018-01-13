class JoinDbsController < ApplicationController
    include JoinDbClient
    before_Filter :authorize

    def show
        # Show JoinDb details
        # Show RemoteDbs
    end

    def new
        # Form for getting info to create the new JoinDb
    end

    def create
        # Creates a new JoinDb
    end
end

