class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]
  def index
    @latest_jobs = Job.published.order(created_at: :desc).limit(6)
    @featured_companies = Company.approved.limit(8)
    if user_signed_in?
      redirect_to redirect_path_for_user
    else
      @recent_jobs = Job.published.active.includes(:company).limit(6)
      @job_count = Job.published.active.count
      @company_count = Company.approved.count
    end
  end

  private

  def redirect_path_for_user
    case current_user.role
    when "admin"
      admin_dashboard_path
    when "recruiter"
      if current_user.can_post_jobs?
        recruiter_dashboard_path
      else
        company_pending_approval_path
      end
    when "job_seeker"
      jobs_path
    else
      root_path
    end
  end
end
