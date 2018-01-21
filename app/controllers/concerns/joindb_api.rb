DB_NAME = "joiner"
PG_USERNAME = "docker"
PG_PASSWORD = "docker"
DB_HOST = "localhost"
CONTAINER_NAME = "joiner"
FILE_DIRECTORY = "/var/lib/postgresql/file_copy"

# Creates a new EC2 instance with a JoinDB and returns relevant info
def create_cloud_db(name)
    # TODO: change this to actually make a new one
    return {
        host: "ec2-18-220-49-14.us-east-2.compute.amazonaws.com",
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

# Adds the user who will own the database
def add_user(username, password, join_db, dbuser = PG_USERNAME, dbpass = PG_PASSWORD)
    masterconn = PG::Connection.open(:host => join_db.host, :dbname => DB_NAME, :user => dbuser,
      :password => dbpass, :port => join_db.port)
    # Only make a superuser if this is the first user being created
    if dbuser == PG_USERNAME
        masterconn.exec("CREATE USER #{username} WITH SUPERUSER")
    else
        masterconn.exec("CREATE USER #{username}")
    end
    res = masterconn.exec("ALTER USER #{username} WITH password '#{password}'")
    
    # If successful, delete the docker user login for security
    if res and dbuser == PG_USERNAME
        masterconn.exec("ALTER USER #{PG_USERNAME} WITH NOLOGIN")
    else
        puts "User creation unsuccessful."
    end
end

# Adds a Postgres FDW
def add_fdw_postgres(join_db, remote_db, remote_password, password)
    conn = open_connection(join_db, password)    
    schema_name = "#{remote_db.database_name}_#{remote_db.schema}"
    begin
        conn.transaction do |conn|
            conn.send_query("CREATE EXTENSION IF NOT EXISTS postgres_fdw") 
        end

        conn.transaction do |c| 
            c.exec("CREATE SERVER #{schema_name}
                FOREIGN DATA WRAPPER postgres_fdw
                OPTIONS (host '#{remote_db.host}', dbname '#{remote_db.database_name}', port '#{remote_db.port || "5432"}')")
            c.exec("CREATE USER MAPPING FOR #{join_db.username}
                SERVER #{schema_name}
                OPTIONS (user '#{remote_db.remote_user}', password '#{remote_password}')")
            
            # Import the schema
            c.exec("CREATE SCHEMA #{schema_name}")
            c.exec("IMPORT FOREIGN SCHEMA #{remote_db.schema}
                FROM SERVER #{schema_name}
                INTO #{schema_name}")
        end
    rescue StandardError
        $stderr.print "Error: #{$!}"
    end
end

# Adds a MySQL FDW
def add_fdw_mysql(join_db, remote_db, remote_password, password)
    conn = open_connection(join_db, password)
    schema_name = "#{remote_db.database_name}"
    begin
        conn.transaction do |conn| 
            conn.exec("CREATE EXTENSION IF NOT EXISTS mysql_fdw")
            conn.get_result
        end

        conn.transaction do |conn| 
            conn.exec("CREATE SERVER #{schema_name}
                FOREIGN DATA WRAPPER mysql_fdw
                OPTIONS (host '#{remote_db.host}', port '#{remote_db.port || "3306"}')")
            conn.exec("CREATE USER MAPPING FOR #{join_db.username}
                SERVER #{schema_name}
                OPTIONS (username '#{remote_db.remote_user}', password '#{remote_password}')")
            # Import the schema
            conn.exec("CREATE SCHEMA #{schema_name}")
            conn.exec("IMPORT FOREIGN SCHEMA \"#{schema_name}\"
                FROM SERVER #{schema_name}
                INTO #{schema_name}")
        end
    rescue StandardError
        $stderr.print "Error: #{$!}"
    end
end

def edit_fdw(join_db, remote_db_new, remote_db_old)
    # TODO: fill this in after MVP
end

def refresh_fdw(join_db, remote_db, password)
    conn = open_connection(join_db, password)
    schema_name = remote_db.postgres? ? "#{remote_db.database_name}_#{remote_db.schema}" : "#{remote_db.database_name}"
    remote_schema = remote_db.postgres? ? "#{remote_db.schema}" : "#{remote_db.database_name}"

    conn.exec("DROP SCHEMA IF EXISTS #{schema_name} CASCADE")
    conn.exec("CREATE SCHEMA #{schema_name}")
    conn.exec("IMPORT FOREIGN SCHEMA \"#{remote_schema}\"
        FROM SERVER #{schema_name}
        INTO #{schema_name}")
end

def delete_fdw(join_db, remote_db, password)
    conn = open_connection(join_db, password)
    
    # TODO: Change this once we have more than just Postgres and MySQL
    schema_name = remote_db.postgres? ? "#{remote_db.database_name}_#{remote_db.schema}" : "#{remote_db.database_name}"

    conn.exec("DROP SERVER IF EXISTS #{schema_name} CASCADE")
    conn.exec("DROP SCHEMA IF EXISTS #{schema_name} CASCADE")
end

# Adds a CSV
def add_csv(files, username, password)
    port = get_port()
    files.each do |file|
        file = file.gsub("\n","")
        puts ""
        puts "Importing #{file}"
        # Copy it to the server
        `docker cp #{file} #{CONTAINER_NAME}:#{FILE_DIRECTORY}`
        
        # Run pgfutter on the server
        puts `docker exec -it #{CONTAINER_NAME} ./pgfutter --user #{username} --pw #{password} --db #{DB_NAME} --ignore-errors csv #{FILE_DIRECTORY}/#{File.basename(file)}`
    end
end

# Adds a MongoDB FDW
def add_mongodb(conn)
end

# Adds a generic FDW
def add_generic(conn)
end

# Open the db connection
def open_connection(join_db, password)
    return PG::Connection.open(:host => join_db.host, :dbname => DB_NAME, :user => join_db.username, :password => password, :port => join_db.port)
end

# Gets the server's port, since with Docker you don't know what port it'll be running on
def get_port()
    return `docker ps | grep 'joiner' | sed "s/.*://g" | sed "s/->.*//g"`.to_i
end

def get_schemas(db, username, password)
    conn = open_connection(db, username, password)

    # Show the schemas
    conn.send_query("SELECT schema_name FROM information_schema.schemata")
    conn.get_result
end

def get_foreign_servers(db, username, password)
    conn = open_connection(db, username, password)

    # Show the servers
    conn.send_query("SELECT srvname, srvoptions FROM pg_foreign_server")
    conn.get_result
end

def get_local_tables(db, username, password)
    conn = open_connection(db, username, password)

    # Show the tables
    conn.send_query("SELECT schemaname, tablename FROM pg_tables WHERE schemaname not in ('pg_catalog', 'information_schema') ORDER BY schemaname desc;")
    conn.get_result
end

def get_foreign_tables(db, username, password)
    conn = open_connection(db, username, password)

    # Show the tables
    conn.send_query("SELECT ftoptions FROM pg_foreign_table")
    conn.get_result
end
