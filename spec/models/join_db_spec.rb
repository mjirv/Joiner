require 'rails_helper'

RSpec.describe JoinDb, type: :model do
  it { should have_many(:remote_dbs).dependent(:destroy) }
  it { should validate_presence_of(:user_id) }
end
