module Api
    module V1
        class ProfilesController < BaseController
            # GET /api/v1/profile
            def show
                render_success(
                    {
                        user: UserSerializer.new(current_user),
                        applications_count: current_user.applications.count,
                        bookmarks_count: current_user.bookmarks.count
                    }
                )
            end

            # PUT /api/v1/profile
            def update
                if current_user.update(profile_params)
                    render_success({
                        user: UserSerializer.new(current_user),
                        message: "Profile updated successfully"
                    })
                else
                    render json: { errors: current_user.errors.full_messages }, status: :unprocessable_content
                end
            end

            private

            def profile_params
                params.require(:user).permit(
                    :first_name, :last_name, :username, :bio, :location, :resume
                )
            end
        end
    end
end
