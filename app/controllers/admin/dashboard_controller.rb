class Admin::DashboardController < Admin::ApplicationController
    def index
        @stats = {
        total_users: User.count,
        job_seekers: User.job_seeker.count,
        recruiters: User.recruiter.count,
        recruiter_managers: User.joins(:recruiter_memberships).where(recruiter_memberships: { role: "manager", status: "approved" }).distinct.count,
        standard_recruiters: User.joins(:recruiter_memberships).where(recruiter_memberships: { role: "standard", status: "approved" }).distinct.count,
        pending_companies: Company.pending.count,
        approved_companies: Company.approved.count,
        rejected_companies: Company.rejected.count,
        pending_recruiter_requests: RecruiterMembership.pending.count,
        total_jobs: Job.count,
        published_jobs: Job.published.count,
        total_applications: Application.count,
        recent_applications: Application.recent.limit(5)
        }

        @recent_users = User.order(created_at: :desc).limit(10)
        @pending_companies = Company.pending.includes(:recruiters).limit(5)
        @pending_recruiter_requests = RecruiterMembership.pending.includes(:user, :company).limit(5)
        @recent_jobs = Job.recent.includes(:company, :posted_by_user).limit(10)
    end
end
