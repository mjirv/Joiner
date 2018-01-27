class JoinDb < ApplicationRecord
    belongs_to :user
    has_many :remote_dbs, dependent: :destroy
    validates :user_id, presence: true

    def create_and_attach_cloud_db(username, password)
        connection_info = create_join_db(username, password, self)
        self.host = connection_info[:host]
        self.port = connection_info[:port]
        self.save

        # Add the user to it
        add_user(username, password, self)
    end
end
