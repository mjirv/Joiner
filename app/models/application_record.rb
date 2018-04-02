class ApplicationRecord < ActiveRecord::Base
  extend JoindbApi
  self.abstract_class = true
end
