class JoinDb < ApplicationRecord
    include AwsFunctions
    belongs_to :user
    has_many :remote_dbs, dependent: :destroy
    enum status: %w(disabled enabled provisioning)
    validates :user_id, presence: true
    validates :name, presence: true
    before_destroy :destroy_ecs_instance

    def create_and_attach_cloud_db(username, password)
        if self.task_arn
            raise "There is already a cloud DB attached"
        end

        connection_info = create_join_db(self.user_id, self.id)
        self.host = connection_info[:dns_name]
        self.port = connection_info[:port]
        self.task_arn = connection_info[:task_arn]

        begin
            self.save!
        rescue Exception => e
            stop_join_db(task_arn)
            raise e
        end

        # Loop until we can connect via postgres and create the user
        tries = 0
        while tries <= 100
            # If we've gotten to 100 tries, something has gone wrong. Raise the error.
            if tries == 100
                JoinDbApi.add_user(username, password, self)
            end

            # Otherwise keep tring to connect until we get there
            begin
                JoindbApi.add_user(username, password, self)
            rescue PG::ConnectionBad
                # If we get an error about the server not running, keep trying
                sleep(10) 
                tries += 1
            else
                break
            end
        end

        # Let them know it's ready
        user = User.find(self.user_id)
        Concurrent::Future.execute{ 
            ApplicationMailer.join_db_ready(user).deliver
        }
    end

    def disable
        # Disable the RemoteDbs
        remote_dbs = RemoteDb.where(
            join_db_id: self.id,
            status: RemoteDb.statuses[:enabled]
        )
        remote_dbs.map(&:disable)

        
        self.status = JoinDb.statuses[:disabled]
        destroy_ecs_instance
        self.save
    end

    private
    def destroy_ecs_instance
        if self.task_arn
            stop_join_db(self.task_arn)
        end
    end
end
