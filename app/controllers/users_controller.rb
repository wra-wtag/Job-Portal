class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update]

  def show
    authorize @user
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Profile updated successfully!'
    else
      render :edit
    end
  end

  def setup
    # Profile setup page for new users
    @user = current_user
    authorize @user
  end

  private

  def set_user
    @user = params[:id] ? User.find(params[:id]) : current_user
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :username, :bio, :location, :resume,
      notification_preferences: {}
    )
  end
end
