class RemoteDbsController < ApplicationController
    include JoinDbClient
    before_Filter :authorize

    def show
        # Show RemoteDb details
        @remote_db = RemoteDb.find(params[:id])
    end

    def new
        # Form for getting info to create the new RemoteDb
    end

    def create
        # Creates a new RemoteDb
    end
end

