class ApplicationRecord < ActiveRecord::Base
  include EnvironmentAware

  self.abstract_class = true

  acts_as_paranoid
  has_paper_trail
end
