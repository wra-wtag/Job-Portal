class JobsController < ApplicationController
  before_action :set_job, only: [ :show, :apply, :submit_application, :bookmark, :unbookmark ]
  before_action :ensure_job_seeker!, only: [ :apply, :submit_application, :bookmark, :unbookmark ]
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @jobs = policy_scope(Job).published.active.includes(:company, :skills)

    @jobs = apply_filters(@jobs)
    @jobs = apply_search(@jobs) if params[:search].present?
    @jobs = apply_sorting(@jobs)
    @jobs = @jobs.page(params[:page]).per(12)
    @employment_types = [
      [ "Full Time", "full_time" ],
      [ "Part Time", "part_time" ],
      [ "Contract", "contract" ],
      [ "Internship", "internship" ],
      [ "Temporary", "temporary" ]
    ]
    @industries = Company.distinct.pluck(:industry).compact.sort
    @locations = Job.distinct.pluck(:location).compact.sort

    @total_jobs = Job.published.active.count
    @companies_hiring = Company.joins(:jobs).where(jobs: { status: :published }).distinct.count
  end

  def show
    @job.increment_views!
    @is_bookmarked = user_signed_in? && current_user.bookmarks.exists?(job: @job)
    @has_applied = user_signed_in? && current_user.applications.exists?(job: @job)
    @application = current_user&.applications&.find_by(job: @job)

    @related_jobs = Job.published.active
                                 .where(company: @job.company)
                                 .where.not(id: @job.id)
                                 .limit(3)
    if @job.skills.any?
      skill_ids = @job.skills.pluck(:id)
      @similar_jobs = Job.published.active.joins(:job_skills)
                                          .where(job_skills: { skill_id: skill_ids })
                                          .where.not(id: @job.id)
                                          .group("jobs.id")
                                          .order("COUNT(job_skills.id) DESC")
                                          .limit(4)
    else
      @similar_jobs = Job.published.active
                                   .where(employment_type: @job.employment_type)
                                   .where.not(id: @job.id)
                                   .limit(4)
    end
  end

  def apply
    authorize @job, :apply?

    redirect_to job_path(@job), alert: "You have already applied for this job." if @has_applied

    @application = current_user.applications.build(job: @job)
  end

  def submit_application
    authorize @job, :apply?

    if current_user.applications.exists?(job: @job)
      redirect_to job_path(@job), alert: "You have already applied for this job."
      return
    end

    @application = current_user.applications.build(application_params)
    @application.job = @job

    if @application.save
      @job.company.recruiters.each do |recruiter|
        Notification.create!(
          user: recruiter,
          kind: "new_job_application",
          title: "New Job Application",
          content: "#{current_user.full_name} applied for #{@job.title}"
        )
      end

      JobApplicationMailer.new_application(@application).deliver_later

      redirect_to applications_path, notice: "Your application has been submitted successfully!"
    else
      render :apply
    end
  end

  def bookmark
    authorize @job, :bookmark?

    unless current_user.bookmarks.exists?(job: @job)
      current_user.bookmarks.create!(job: @job)
      flash[:notice] = "Job bookmarked successfully!"
    else
      flash[:alert] = "Job is already bookmarked."
    end

    redirect_back(fallback_location: job_path(@job))
  end

  def unbookmark
    authorize @job, :bookmark?

    bookmark = current_user.bookmarks.find_by(job: @job)
    if bookmark
      bookmark.destroy
      flash[:notice] = "Job removed from bookmarks."
    end

    redirect_back(fallback_location: job_path(@job))
  end

  private

  def set_job
    @job = Job.find(params[:id])
    @has_applied = user_signed_in? && current_user.applications.exists?(job: @job)
  end

  def ensure_job_seeker!
    redirect_to root_path, alert: "Access denied." unless current_user&.job_seeker?
  end

  def application_params
    params.require(:application).permit(:cover_letter, :resume)
  end

  def apply_filters(jobs)
    jobs = jobs.where(employment_type: params[:employment_type]) if params[:employment_type].present?
    jobs = jobs.where(is_remote: true) if params[:remote] == "true"
    jobs = jobs.joins(:company).where(companies: { industry: params[:industry] }) if params[:industry].present?
    jobs = jobs.where("jobs.location ILIKE ?", "%#{params[:location]}%") if params[:location].present?

    if params[:salary_min].present?
      jobs = jobs.where("salary_min >= ?", params[:salary_min])
    end

    if params[:salary_max].present?
      jobs = jobs.where("salary_max <= ?", params[:salary_max])
    end

    jobs
  end

  def apply_search(jobs)
    search_term = params[:search].strip
    jobs.where(
      "jobs.title ILIKE ? OR jobs.description ILIKE ? OR companies.name ILIKE ?",
      "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"
    ).joins(:company)
  end

  def apply_sorting(jobs)
    case params[:sort]
    when "newest"
      jobs.order(published_at: :desc)
    when "oldest"
      jobs.order(published_at: :asc)
    when "salary_high"
      jobs.order(salary_max: :desc, salary_min: :desc)
    when "salary_low"
      jobs.order(salary_min: :asc, salary_max: :asc)
    when "company"
      jobs.joins(:company).order("companies.name ASC")
    else
      jobs.order(published_at: :desc)
    end
  end
end
