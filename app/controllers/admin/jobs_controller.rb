class Admin::JobsController < Admin::ApplicationController
  before_action :set_job, only: [ :show, :edit, :update, :destroy ]

  def index
    @jobs = Job.includes(:company, :posted_by_user)
                .order(created_at: :desc)
                .page(params[:page])

    @jobs = @jobs.where(status: params[:status].to_sym) if params[:status].present?

    if params[:search].present?
      search_term = "%#{params[:search].strip}%"
      @jobs = @jobs.where('jobs.title ILIKE :search OR
                          jobs.description ILIKE :search OR
                          jobs.location ILIKE :search OR
                          companies.name ILIKE :search OR
                          users.email ILIKE :search',
                          search: search_term)
                  .joins(:company, :posted_by_user)
    end

    @draft_count = Job.draft.count
    @published_count = Job.published.count
    @closed_count = Job.closed.count
  end

  def show
    @applications = @job.applications.includes(:user).recent
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to admin_job_path(@job), notice: "Job updated successfully!"
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to admin_jobs_path, notice: "Job deleted successfully!"
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :employment_type, :salary_min, :salary_max,
                                :currency, :status, :location, :is_remote, :expires_at, :application_deadline)
  end
end
