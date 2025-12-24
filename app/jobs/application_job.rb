class ApplicationJob < ActiveJob::Base
  include EnvironmentAware
end
