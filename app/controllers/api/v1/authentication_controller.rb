module Api
  module V1
    class AuthenticationController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :login, :signup ]

      # POST /api/v1/auth/signup
      def signup
        Rails.logger.info "Signup params: #{params.to_unsafe_h}"
        user = User.new(signup_params)
        user.skip_confirmation!

        if user.save
          token = JsonWebToken.encode(user_id: user.id)
          render_success(
            {
              token: token,
              user: UserSerializer.new(user)
            },
            :created
          )
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: login_params[:email])

        if user&.valid_password?(login_params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render_success(
            {
              token: token,
              user: UserSerializer.new(user)
            }
          )
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        render_success({ message: "Logged out successfully" })
      end

      # GET /api/v1/auth/me
      def me
        render_success({ user: UserSerializer.new(current_user) })
      end

      private

      def signup_params
        params.require(:user).permit(
          :email, :password, :password_confirmation,
          :first_name, :last_name, :username, :role,
          :bio, :location
        )
      end

      def login_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
