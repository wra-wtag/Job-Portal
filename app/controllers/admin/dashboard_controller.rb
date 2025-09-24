class Admin::DashboardController < ApplicationController
    def index
        @stats = {
        total_users: User.count,
        job_seekers: User.job_seekers.count,
        recruiters: User.recruiters.count,
        pending_companies: Company.pending.count,
        approved_companies: Company.approved.count,
        rejected_companies: Company.rejected.count,
        total_jobs: Job.count,
        published_jobs: Job.published.count,
        total_applications: Application.count,
        recent_applications: Application.recent.limit(5)
        }

        @recent_users = User.order(created_at: :desc).limit(10)
        @pending_companies = Company.pending.includes(:recruiters).limit(5)
        @recent_jobs = Job.recent.includes(:company, :posted_by_user).limit(10)
    end
end
