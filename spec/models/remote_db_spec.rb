require 'rails_helper'

RSpec.describe RemoteDb, type: :model do
  it { should validate_presence_of(:join_db_id) }
  it { should belong_to(:join_db) }
end
