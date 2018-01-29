class JoinDb < ApplicationRecord
    include AwsFunctions
    belongs_to :user
    has_many :remote_dbs, dependent: :destroy
    validates :user_id, presence: true
    before_destroy :destroy_ecs_instance

    def create_and_attach_cloud_db(username, password)
        connection_info = create_join_db()
        self.host = connection_info[:dns_name]
        self.port = connection_info[:port]
        self.task_arn = connection_info[:task_arn]
        self.save

        # Add the user to it
        # Wait a while to make sure this works
        # TODO: Make this asynchronous or some shit
        sleep(180)
        add_user(username, password, self)
    end

    private
    def destroy_ecs_instance
        stop_join_db(self.task_arn)
    end
end
