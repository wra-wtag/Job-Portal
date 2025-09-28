class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update]
    before_action :authorize_job_seeker!, only: [:edit, :update, :setup]

    def show
        authorize @user
    end

    def edit
        authorize @user
    end

    def update
        authorize @user
        if @user.update(user_params)
            redirect_to profile_path, notice: "Profile Added Successfully"
        else
            render :edit
        end
    end

    def setup
        @user = current_user
        authorize @user
    end

    private

    def set_user
        @user = params[:id] ? User.find(params[:id]) : current_user
    end

    def user_params
        params.require(:user).permit(
            :first_name, :last_name, :username, :bio, :location, :resume, skills_list: [], notification_preferences: {}
        )
    end

    def authorize_job_seeker!
        return if current_user.job_seeker?

        flash[:alert] = "Access denied: Only job seekers can edit profiles."
        redirect_to root_path
    end
end
