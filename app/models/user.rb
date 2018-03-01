class User < ApplicationRecord
    has_secure_password
    has_many :join_dbs, dependent: :destroy
    validates :email, uniqueness: { case_sensitive: false }
    validates :name, uniqueness: { case_sensitive: false }
    validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
    before_create :confirmation_token
    enum tier: %w(trial individual team enterprise admin)
    enum status: %w(disabled enabled)

    def email_activate
        self.email_confirmed = true
        self.confirm_token = nil
        self.save!
    end

    def disable
        # Make sure all the user's JoinDbs turn off
        join_dbs = JoinDb.where(user_id: self.id)
        join_dbs.map do |jdb|
            jdb.disable
        end

        self.status = User.statuses[:disabled]
        self.save
    end

    private
    def confirmation_token
        if self.confirm_token.blank?
            self.confirm_token = SecureRandom.urlsafe_base64.to_s
        end
    end
end
