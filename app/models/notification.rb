class Notification < ApplicationRecord
    belongs_to :user
    enum notification_type: %w(general success error)
    enum status: %w(disabled enabled)
    validates :user_id, presence: true
    validates :message, presence: true
    validates :notification_type, presence: true
    validates :status, presence: true
end
