class Recruiter::DashboardController < Recruiter::ApplicationController
  def index
    @company = current_company
    @user_membership = current_user.recruiter_memberships.approved.find_by(company: @company)
    @is_manager = @user_membership&.manager?

    @stats = {
      total_jobs: @company.jobs.count,
      published_jobs: @company.jobs.published.count,
      draft_jobs: @company.jobs.where(status: "draft").count,
      closed_jobs: @company.jobs.where(status: "closed").count,
      total_applications: Application.joins(:job).where(jobs: { company: @company }).count,
      new_applications: Application.joins(:job).where(jobs: { company: @company }, applications: { status: "applied" }).count,
      shortlisted_applications: Application.joins(:job).where(jobs: { company: @company }, applications: { status: "shortlisted" }).count
    }

    if @is_manager
      @team_stats = {
        total_recruiters: @company.recruiter_memberships.approved.count,
        pending_requests: @company.recruiter_memberships.approved.count,
        managers: @company.recruiter_memberships.approved.managers.count,
        standard_recruiters: @company.recruiter_memberships.approved.standard.count
      }
    end

    @recent_jobs = @company.jobs
                           .includes(:applications)
                           .order(created_at: :desc)
                           .limit(5)

    @recent_applications = Application.joins(:job)
                                      .includes(:user, job: :company)
                                      .where(jobs: { company: @company })
                                      .order(applied_at: :desc)
                                      .limit(10)

    if @is_manager
      @pending_team_requests = @company.recruiter_memberships.pending.includes(:user).limit(3)
    end

    @job_views_data = @company.jobs.published
                            .group(:title)
                            .sum(:views_count)
                            .transform_keys { |k| k.length > 20 ? "#{k[0, 17]}..." : k }

    @job_views_data = {} if @job_views_data.empty?
    @max_views = @job_views_data.values.max || 0

    @applications_by_status = Application.joins(:job)
                                         .where(jobs: { company: @company })
                                         .group(:status)
                                         .count
  end
end
