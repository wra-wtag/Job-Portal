class Recruiter::JobsController < Recruiter::ApplicationController
  before_action :set_job, only: [ :show, :edit, :update, :destroy, :toggle_status ]

  def index
    @jobs = current_company.jobs
                           .includes(:applications)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(10)

    @jobs = @jobs.where(status: params[:status]) if params[:status].present?

    @stats = {
      all: current_company.jobs.count,
      draft: current_company.jobs.where(status: "draft").count,
      published: current_company.jobs.published.count,
      closed: current_company.jobs.where(status: "closed").count
    }
  end

  def show
    @applications = @job.applications
                        .includes(:user)
                        .order(applied_at: :desc)
                        .page(params[:page])
                        .per(10)

    @applications = @applications.where(status: params[:app_status]) if params[:app_status].present?

    @application_stats = {
      total: @job.applications.count,
      applied: @job.applications.where(status: "applied").count,
      viewed: @job.applications.where(status: "viewed").count,
      shortlisted: @job.applications.where(status: "shortlisted").count,
      rejected: @job.applications.where(status: "rejected").count,
      hired: @job.applications.where(status: "hired").count
    }
  end

  def new
    @job = current_company.jobs.build
    authorize @job
  end

  def create
    @job = current_company.jobs.build(job_params)
    @job.posted_by_user = current_user
    authorize @job

    if @job.save
      if params[:skills].present?
        skill_names = params[:skills].split(",").map(&:strip)
        skill_names.each do |skill_name|
          next if skill_name.blank?
          skill = Skill.find_or_create_by_name(skill_name)
          @job.job_skills.create!(skill: skill, required: true)
        end
      end

      if params[:publish] == "true"
        @job.update!(status: "published", published_at: Time.current)
        redirect_to recruiter_job_path(@job), notice: "Job was successfully created and published!"
      else
        redirect_to recruiter_job_path(@job), notice: "Job was successfully created as draft!"
      end
    else
      render :new
    end
  end

  def edit
    authorize @job
  end

  def update
    authorize @job

    if @job.update(job_params)
      if params[:skills].present?
        @job.job_skills.destroy_all

        skill_names = params[:skills].map(&:strip)
        skill_names.each do |skill_name|
          next if skill_name.blank?
          skill = Skill.find_or_create_by_name(skill_name)
          @job.job_skills.create!(skill: skill, required: true)
        end
      end

      redirect_to recruiter_job_path(@job), notice: "Job was successfully updated!"
    else
      render :edit
    end
  end

  def destroy
    authorize @job
    @job.destroy
    redirect_to recruiter_jobs_path, notice: "Job was successfully deleted!"
  end

  def toggle_status
    authorize @job

    case @job.status
    when "draft"
      @job.update!(status: "published", published_at: Time.current)
      flash[:notice] = "Job published successfully!"
    when "published"
      @job.update!(status: "closed")
      flash[:notice] = "Job closed successfully!"
    when "closed"
      @job.update!(status: "published")
      flash[:notice] = "Job reopened successfully!"
    end

    redirect_back(fallback_location: recruiter_job_path(@job))
  end

  private

  def set_job
    @job = current_company.jobs.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :employment_type, :salary_min, :salary_max,
                                :currency, :location, :is_remote, :expires_at, :application_deadline)
  end
end
