class RemoteDbsController < ApplicationController
    include JoinDbClient
    before_Filter :authorize

    def show
        # Show RemoteDb details
    end

    def new
        # Form for getting info to create the new RemoteDb
    end

    def create
        # Creates a new RemoteDb
    end
end

