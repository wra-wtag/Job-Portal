class UsersController < ApplicationController
    before_action :set_user, only: [ :show, :edit, :update ]
    before_action :authorize_job_seeker!, only: [ :edit, :update, :setup ]

    def show
        authorize @user
    end

    def edit
        authorize @user
    end

    def update
        authorize @user

        skills = params[:user].delete(:skills_list)

        if @user.update(user_params)
            if skills
            @user.skills = skills.map do |skill_name|
                Skill.where("LOWER(name) = ?", skill_name.downcase).first_or_create(name: skill_name)
            end
            end

            redirect_to profile_path, notice: "Profile Updated Successfully"
        else
            render :edit, status: :unprocessable_content
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
        permitted = [
            :first_name, :last_name, :username, :bio, :location, :resume, notification_preferences: {}
        ]

        permitted += [ :password, :password_confirmation ] if params[:user][:password].present?

        params.require(:user).permit(permitted)
    end

    def authorize_job_seeker!
        return if current_user.job_seeker?

        flash[:alert] = "Access denied: Only job seekers can edit profiles."
        redirect_to root_path
    end
end
