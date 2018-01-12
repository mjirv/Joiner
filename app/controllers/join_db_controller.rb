class JoinDbController < ApplicationController
    include JoinDbClient

    # POST /joindb?db_user=XXX&db_pass=XXX&
    # Creates a db and associates it to the user
    def setup
        db_user = params[:db_user]
        db_pass = params[:db_pass]
        # We'll need a way to associate users to dbs
        # Also, we probably want to check that they don't have an existing one

        # The cloudddddd
        db = new_db()

        # Register them
        # TODO: add_user needs to use db
        add_user(db, db_user, db_pass)
        
        # TODO: We may not need this depending on how register_user is implemented
        login()
        
        # TODO: Check for failure, give error message as appropriate
        render json(get_db(db.host, db.name))
    end

    def login
        # TODO: This probably isn't necessary, and can be handled
        # by the overall user/session controller
    end
    
    # GET /joindb/:id
    def get_db(db_host, db_name)
        # TODO: Add validation to make sure the user has access
        if params[:id]
            db = JoinDb.find(:id)
            db_host = db.host
            db_name = db.name
        end

        return {
            host: db_host,
            name: db_name
        }
    end
    
    # POST /joindb/:id/add_fdw/:remote_db_id
    # Adds a foreign data wrapper 
    def add_db_prompt
        join_db = JoinDb.find(params[:id])
        db_info = get_db(join_db.host, join_db.name))

        remote_db = RemoteDb.find(params[:remote_db_id])
        db_type = RemoteDb.db_type
        fdw_type = DB_FDW_MAPPING[db_type]

        # TODO: Make the client use a default superuser so I don't have to store the user's password
        db_user = params[:db_user]
        db_pass = params[:db_pass]

        remote_db_user = remote_db.username
        remote_db_pass = remote_db.password
        remote_host = remote_db.host
        remote_port = remote_db.port
        remote_db_name = remote_db.join_db
        remote_schema = remote_db.schema

        case fdw_type
        when DB_FDW_MAPPING[:Postgres]
            add_fdw_postgres(db_info, fdw_type, db_user, db_pass, remote_db_user, remote_db_pass, remote_host, remote_db_name, remote_schema, remote_port)
        when DB_FDW_MAPPING[:MySQL]
            add_fdw_mysql(db_info, fdw_type, db_user, db_pass, remote_db_user, remote_db_pass, remote_host, remote_db_name, remote_port) 
        end

        # TODO: Return something indicating if we've succeeded or failed
    end

    # POST /joindb/:id/add_csv/:csv_id
    # Adds CSVs as new tables
    def add_csv_prompt
        join_db = JoinDb.find(params[:id])
        db_info = get_db(join_db.host, join_db.name)

        # TODO: Validate that user has access to this CSV
        path_to_file = CsvFile.find(params[:csv_id]).path
        db_user = params[:db_user]
        db_pass = params[:db_pass]

        files = path_to_file.split(",")
        add_csv(db_info, files, db_user, db_pass)

        # TODO: Return something indicating if we've succeeded or failed
    end

    # GET /joindb/:id/details
    def get_details_prompt
        join_db = JoinDb.find(params[:id])
        db_info = get_db(params[:db_host], params[:db_name])
        connection_details = {
            host: join_db.host,
            port: join_db.port,
            username: join_db.primary_user,
            schemas: get_schemas(db_info, db_user, db_pass),
            foreign_servers: get_foreign_servers(db_info, db_user, db_pass),
            local_tables: get_local_tables(db_info, db_user, db_pass),
            foreign_tables: get_foreign_tables(db_info, db_user, db_pass),
        }

        render json(connection_details)
    end

    private
    def new_db
        join_db = JoinDb.create!(user_id)
        return join_db
    end
end

