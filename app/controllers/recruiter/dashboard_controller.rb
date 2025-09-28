class Recruiter::DashboardController < Recruiter::ApplicationController
  def index
    @company = current_company

    @stats = {
      total_jobs: @company.jobs.count,
      published_jobs: @company.jobs.published.count,
      draft_jobs: @company.jobs.where(status: "draft").count,
      closed_jobs: @company.jobs.where(status: "closed").count,
      total_applications: Application.joins(:job).where(jobs: { company: @company }).count,
      new_applications: Application.joins(:job).where(jobs: { company: @company }, applications: { status: 'applied' }).count,
      shortlisted_applications: Application.joins(:job).where(jobs: { company: @company }, applications: { status: "shortlisted" }).count
    }

    @recent_jobs = @company.jobs
                           .includes(:applications)
                           .order(created_at: :desc)
                           .limit(5)
    
    @recent_applications = Application.joins(:job)
                                      .includes(:user, job: :company)
                                      .where(jobs: { company: @company })
                                      .order(applied_at: :desc)
                                      .limit(10)
    
    @job_views_data = @company.jobs.published
                              .group(:title)
                              .sum(:views_count)
                              .transform_keys { |k| truncate(k, lenght: 20) }

    @applications_by_status = Application.joins(:job)
                                         .where(jobs: { company: @company })
                                         .group(:status)
                                         .count
  end
end
