module Api
  module V1
    class Base < Grape::API
      version "v1", using: :path
      format :json

      helpers do
        def current_user
          @current_user ||= authenticate_user_from_token
        end

        def authenticate_user_from_token
          token = headers["Authorization"]&.split(" ")&.last
          return nil unless token
          User.find_by(authentication_token: token)
        end

        def authenticate!
          error!("401 Unauthorized", 401) unless current_user
        end
      end

      rescue_from ActiveRecord::RecordNotFound do
        error!("Record not found", 404)
      end

      rescue_from :all do |e|
        error!({ error: e.message }, 500)
      end

      require_relative "jobs_api"
      require_relative "companies_api"
      require_relative "applications_api"

      mount Api::V1::JobsAPI
      mount Api::V1::CompaniesAPI
      mount Api::V1::ApplicationsAPI
    end
  end
end
