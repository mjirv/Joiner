require 'rails_helper'

#FactoryBot.find_definitions

describe "Viewing a RemoteDb", type: :request do
    it "denies access if you're not logged in"

    it "denies access if you're the wrong user"

    it "succeeds if you're logged in and the right user"
end

describe "Creating a RemoteDb", type: :request do
    it "denies access if you're not logged in" 

    it "denies access if you're the wrong user"

    it "succeeds if you're logged in and the right user"

    it "is given a host and port on creation"
end

describe "Deleting a RemoteDb", type: :request do
    it "deletes the JoinDB if you're logged in and the right user"

    it "fails if you're not logged in"

    it "fails if you're the wrong user"
end