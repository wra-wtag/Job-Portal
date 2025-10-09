module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :authenticate_user!, raise: false
      skip_before_action :verify_authenticity_token
      before_action :authenticate_api_user!
      before_action :ensure_json_request

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized if defined?(Pundit)

      private

      def ensure_json_request
        request.format = :json
      end

      def authenticate_api_user!
        header = request.headers["Authorization"]
        token = header.split(" ").last if header

        if token
          decoded = JsonWebToken.decode(token)
          if decoded
            @current_user = User.find_by(id: decoded[:user_id])
            return if @current_user
          end
        end

        render_unauthorized
      end

      def current_user
        @current_user
      end

      def render_unauthorized(message = "Unauthorized access")
        render json: { error: message }, status: :unauthorized
      end

      def render_error(message, status = :unprocessable_content)
        render json: { error: message }, status: status
      end

      def render_success(data, status = :ok, meta = {})
        response = { success: true, data: data }
        response[:meta] = meta if meta.present?
        render json: response, status: status
      end

      def record_not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def record_invalid(exception)
        render json: { error: exception.record.errors.full_messages }, status: :unprocessable_content
      end

      def user_not_authorized
        render json: { error: "You are not authorized to perform this action" }, status: :forbidden
      end
    end
  end
end
