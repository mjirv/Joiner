class JoinDbsController < ApplicationController
    include JoinDbClient
    before_Filter :authorize

    def show
        # Show JoinDb details
        @join_db = JoinDb.find(params[:id])
        # Show RemoteDbs
        @remote_dbs = RemoteDb.where(join_db_id: params[:id])
    end

    def new
        # Form for getting info to create the new JoinDb
    end

    def create
        # Creates a new JoinDb
    end
end

