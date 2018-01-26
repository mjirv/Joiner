require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:join_dbs) }
  # It should enforce valid email format
  # It should enforce unique username
  # It should enforce unique email
end
