class JoinDb < ApplicationRecord
    include AwsFunctions
    belongs_to :user
    has_many :remote_dbs, dependent: :destroy
    validates :user_id, presence: true
    validates :name, presence: true
    before_destroy :destroy_ecs_instance

    def create_and_attach_cloud_db(username, password)
        if self.task_arn
            raise "There is already a cloud DB attached"
        end

        connection_info = create_join_db()
        self.host = connection_info[:dns_name]
        self.port = connection_info[:port]
        self.task_arn = connection_info[:task_arn]

        begin
            self.save!
        rescue Exception => e
            stop_join_db(task_arn)
            raise e
        end

        # Add the user to it
        # Wait a while to make sure this works
        # TODO: Make this a callback based on success of create_join_db()
        sleep(180)
        add_user(username, password, self)
    end

    private
    def destroy_ecs_instance
        if self.task_arn
            stop_join_db(self.task_arn)
        end
    end
end
