DB_NAME = "joiner"
PG_USERNAME = "docker"
PG_PASSWORD = "docker"
DB_HOST = "localhost"
CONTAINER_NAME = "joiner"
FILE_DIRECTORY = "/var/lib/postgresql/file_copy"

# Adds the user who will own the database
def add_user(username, password, dbuser = PG_USERNAME, dbpass = PG_PASSWORD)
    masterconn = PG::Connection.open(:host => DB_HOST, :dbname => DB_NAME, :user => dbuser,
      :password => dbpass, :port => get_port())
    # Only make a superuser if this is the first user being created
    if dbuser == PG_USERNAME
        masterconn.exec("CREATE USER #{username} WITH SUPERUSER")
    else
        masterconn.exec("CREATE USER #{username}")
    end
    res = masterconn.exec("ALTER USER #{username} WITH password '#{password}'")
    
    #If successful, delete the docker user login for security
    if res
        masterconn.exec("ALTER USER #{PG_USERNAME} WITH NOLOGIN")
    else
        puts "User creation unsuccessful."
    end
end

# If we're connecting to a server on the host, we want to give it the host IP
def dockerize_localhost(remotehost)
    if remotehost == "localhost" or remotehost == "127.0.0.1"
        remotehost = `ifconfig | grep "docker0" -A 1 | grep "inet" | cut -d ":" -f 2 | cut -d " " -f 1`
    end
    return remotehost
end

# Adds a Postgres FDW
def add_fdw_postgres(fdw_type, username, password, remoteuser, remotepass, remotehost, remotedbname, remoteschema, remoteport=5432)
    remotehost = dockerize_localhost(remotehost)
    conn = open_connection(DB_NAME, username, password)    
    schema_name = "#{remotedbname}_#{remoteschema}"
    begin
        conn.transaction do |conn|
            conn.send_query("CREATE EXTENSION IF NOT EXISTS #{fdw_type}") 
        end

        conn.transaction do |c| 
            c.exec("CREATE SERVER #{schema_name}
                FOREIGN DATA WRAPPER #{fdw_type}
                OPTIONS (host '#{remotehost}', dbname '#{remotedbname}', port '#{remoteport}')")
            c.exec("CREATE USER MAPPING FOR #{username}
                SERVER #{schema_name}
                OPTIONS (user '#{remoteuser}', password '#{remotepass}')")
            
            # Import the schema
            c.exec("CREATE SCHEMA #{schema_name}")
            c.exec("IMPORT FOREIGN SCHEMA #{remoteschema}
                FROM SERVER #{schema_name}
                INTO #{schema_name}")
        end
    rescue StandardError
        $stderr.print "Error: #{$!}"
    end
end

# Adds a MySQL FDW
def add_fdw_mysql(fdw_type, username, password, remoteuser, remotepass, remotehost, remotedbname, remoteport=3306)
    remotehost = dockerize_localhost(remotehost)
    conn = open_connection(DB_NAME, username, password)
    schema_name = "#{remotedbname}"
    begin
        conn.transaction do |conn| 
            conn.exec("CREATE EXTENSION IF NOT EXISTS #{fdw_type}")
            conn.get_result
        end

        conn.transaction do |conn| 
            conn.exec("CREATE SERVER #{schema_name}
                FOREIGN DATA WRAPPER #{fdw_type}
                OPTIONS (host '#{remotehost}', port '#{remoteport}')")
            conn.exec("CREATE USER MAPPING FOR #{username}
                SERVER #{schema_name}
                OPTIONS (username '#{remoteuser}', password '#{remotepass}')")
            # Import the schema
            conn.exec("CREATE SCHEMA #{schema_name}")
            conn.exec("IMPORT FOREIGN SCHEMA #{schema_name}
                FROM SERVER #{schema_name}
                INTO #{schema_name}")
        end
    rescue StandardError
        $stderr.print "Error: #{$!}"
    end
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
def open_connection(db, username, password)
    return PG::Connection.open(:host => db[:host], :dbname => db[:name], :user => username,
      :password => password, :port => get_port())
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
