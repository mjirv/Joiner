require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User.new(name: "mjirv", email: "mjirv@example.com", password: "test123") }
  it { should have_many(:join_dbs).dependent(:destroy) }
  # It should enforce valid email format
  it { should allow_value("michael.j.irvine@gmail.com").for(:email)}
  it { should_not allow_value("foo").for(:email) }
  # It should enforce unique username
  it { should validate_uniqueness_of(:name).case_insensitive}
  # It should enforce unique email
  it { should validate_uniqueness_of(:email).case_insensitive }

end
