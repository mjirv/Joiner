module JoindbApi
    require_relative './joindb_api_methods'
    PG_USERNAME = "docker"
    PG_PASSWORD = "docker"
    CONTAINER_NAME = "joiner"
    FILE_DIRECTORY = "/var/lib/postgresql/file_copy"
    DB_NAME = "joiner"

    class JoinDBApiMethods
        extend JoindbApiMethods
    end

    # Creates a new EC2 instance with a JoinDB and returns relevant info
    def create_cloud_db(name)
        # TODO: change this to actually make a new one
        return {
            host: "ec2-18-217-102-177.us-east-2.compute.amazonaws.com",
            port: 5432
        }
    end

    # Creates a new JoinDB and returns relevant information about it
    def create_join_db(username, password, join_db)
        # Call AWS API to create a new instance, get back the hostname
        connection_info = create_cloud_db(join_db.name)

        # Return the host and port
        return connection_info

    end

    # Destroys a JoinDB
    def destroy_join_db(join_db)
        # Calls AWS API to destroy the db
        destroy_cloud_db(join_db.host)
    end

    def edit_fdw(join_db, remote_db_new, remote_db_old)
        # TODO: fill this in after MVP
    end

    # Drops and re-adds the foreign server/schema to refresh tables
    # TODO: There's gotta be a better way of doing this
    def refresh_fdw(join_db, remote_db, password)
        conn = open_connection(join_db, password)
        schema_name = (remote_db.postgres? or remote_db.redshift?) ? "#{remote_db.database_name}_#{remote_db.schema}" : "#{remote_db.database_name}"
        remote_schema = (remote_db.postgres? or remote_db.redshift?) ? "#{remote_db.schema}" : "#{remote_db.database_name}"
        options = (remote_db.postgres? or remote_db.redshift?) ? "" : "OPTIONS (
            odbc_DATABASE '#{schema_name}'
        )"

        conn.transaction do |t|
            t.exec("DROP SCHEMA IF EXISTS #{schema_name} CASCADE")
            t.exec("CREATE SCHEMA #{schema_name}")
            t.exec("IMPORT FOREIGN SCHEMA \"#{remote_schema}\"
                FROM SERVER #{schema_name}
                INTO #{schema_name}
                #{options}")
        end
        conn.close()
    end

    def delete_fdw(join_db, remote_db, password)
        conn = open_connection(join_db, password)
        
        # Change if other db types have different schema names in future
        schema_name = (remote_db.postgres? or remote_db.redshift?) ? "#{remote_db.database_name}_#{remote_db.schema}" : "#{remote_db.database_name}"

        if schema_name
            conn.exec("DROP SERVER IF EXISTS #{schema_name} CASCADE")
            conn.exec("DROP SCHEMA IF EXISTS #{schema_name} CASCADE")
        end
        conn.close()
    end

    def delete_csv(join_db, remote_db, password)
        conn = open_connection(join_db, password)
        conn.exec("DROP TABLE IF EXISTS import.#{remote_db.table_name}")
        conn.close()
    end

    # The following methods are wrappers over the open source
    # methods in joindb_api_methods.rb

    def open_connection(join_db, password)
        JoinDBApiMethods.open_connection(DB_NAME, join_db.host, join_db.username, password, join_db.port)
    end

    def add_user(username, password, join_db)
        JoinDBApiMethods.add_user(username: username, password: password, db_host: join_db.host, db_name: DB_NAME, port: join_db.port)
    end

    def add_fdw_postgres(join_db, remote_db, remote_password, password)
        JoinDBApiMethods.add_fdw_postgres(username: join_db.username, password: password, db_name: DB_NAME, db_host: join_db.host, port: join_db.port, remote_user: remote_db.remote_user, remote_pass: remote_password, remote_host: remote_db.host, remote_db_name: remote_db.database_name, remote_schema: remote_db.schema, remote_port: remote_db.port)
    end

    def add_fdw_mysql(join_db, remote_db, remote_password, password)
        JoinDBApiMethods.add_fdw_other(username: join_db.username, password: password, db_name: DB_NAME, db_host: join_db.host, port: join_db.port, remote_user: remote_db.remote_user, remote_pass: remote_password, remote_host: remote_db.host, remote_db_name: remote_db.database_name, remote_port: remote_db.port, driver_type: "MySQL")
    end

    def add_fdw_sql_server(join_db, remote_db, remote_password, password)
        JoinDBApiMethods.add_fdw_other(username: join_db.username, password: password, db_name: DB_NAME, db_host: join_db.host, port: join_db.port, remote_user: remote_db.remote_user, remote_pass: remote_password, remote_host: remote_db.host, remote_db_name: remote_db.database_name, remote_port: remote_db.port, driver_type: "SQL Server")
    end

    def add_csv(join_db, remote_db, password)
        # Add it as a table using pgfutter
        JoinDBApiMethods.add_csv(
            files: [remote_db.filepath],
            username: join_db.username,
            password: password,
            db_name: DB_NAME,
            db_host: join_db.host,
            port: join_db.port
        )
    end
end
