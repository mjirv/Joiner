class ApplicationRecord < ActiveRecord::Base
  include JoindbApi
  self.abstract_class = true
end
