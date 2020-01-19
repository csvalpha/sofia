module Requests
  module JsonHelpers
    def json
      JSON.parse(request.body)
    end
  end
end
