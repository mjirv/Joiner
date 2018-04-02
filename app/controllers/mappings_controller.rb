class MappingsController < ApplicationController
    def create
        mapping = Mapping.new(mapping_params)
        if create_mapping(
            join_db: JoinDb.find(mapping_params[:join_db_id]),
            remote_db_one: RemoteDb.find(mapping_params[:remote_db_one_id]),
            table_one: mapping_params[:table_one],
            column_one: mapping_params[:column_one],
            remote_db_two: RemoteDb.find(mapping_params[:remote_db_two_id]), 
            table_two: mapping_params[:table_two], 
            column_two: mapping_params[:column_two], 
            password: session[:join_db_password]
        )
            mapping.save!
        else
            raise "Your mapping could not be saved"
        end
    end

    def new
        @page_title = "New Mapping"
        @join_db_id = params[:join_db].to_i
        confirm_join_db_password(@join_db_id)

        @remote_dbs = RemoteDb.where(join_db_id: @join_db_id, status: 'enabled')
        @mapping = Mapping.new
    end

    def new_tables
        @page_title = "New Mapping"
        @join_db_id = params[:join_db].to_i
        confirm_join_db_password(@join_db_id)

        @remote_db_one = RemoteDb.find(params[:remote_db_one])
        @table_one_options = @remote_db_one.get_tables(session[:join_db_password])
        @remote_db_two = RemoteDb.find(params[:remote_db_two])
        @table_two_options = @remote_db_two.get_tables(session[:join_db_password])
    end

    def new_columns
        # Set things up
        @page_title = "New Mapping"
        @join_db_id = params[:join_db].to_i
        confirm_join_db_password(@join_db_id)
        @table_one = params[:table_one]
        @table_two = params[:table_two]

        # Get the columns from JoinDbApi.get_columns
        @join_db = JoinDb.find(@join_db_id)
        @remote_db_one = RemoteDb.find(params[:remote_db_one])
        @column_one_options = get_columns(@join_db, @remote_db_one, @table_one, session[:join_db_password])
        @remote_db_two = RemoteDb.find(params[:remote_db_two])
        @column_two_options = get_columns(@join_db, @remote_db_two, @table_two, session[:join_db_password])
        
        # TODO: make sure to validate that the owner is the right person
    end

    private
    def mapping_params
        params.require(:mapping).permit(:join_db_id, :remote_db_one_id, :remote_db_two_id, :table_one, :column_one, :table_two, :column_two)
    end
end