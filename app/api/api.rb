module Api
    class Root < Grape::API
        prefix "api"
        format :json

        require_relative "v1/base"
        require_relative "v1/jobs_api"
        require_relative "v1/companies_api"
        require_relative "v1/applications_api"

        mount Api::V1::Base
    end
end
