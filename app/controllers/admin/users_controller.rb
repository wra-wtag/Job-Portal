class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.includes(:companies, :applications)
                 .order(created_at: :desc)
                 .page(params[:page])

    @users = @users.where(role: params[:role]) if params[:role].present?

    @job_seekers_count = User.job_seeker.count
    @recruiters_count = User.recruiter.count
    @admins_count = User.admin.count
  end

  def show
    case @user.role
    when "job_seeker"
      @applications = @user.applications.includes(:job)
      @bookmarks = @user.bookmarks.includes(:job)
    when "recruiter"
      @companies = @user.companies
      @posted_jobs = @user.posted_jobs.includes(:company)
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User updated successfully!"
    else
      render :edit
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete yourself!"
      return
    end

    @user.destroy
    redirect_to admin_users_path, notice: "User deleted successfully!"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :role, :bio, :location, :email_verified)
  end
end
