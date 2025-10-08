class Admin::AnalyticsController < ApplicationController
  def index
    @date_range = params[:date_range] || "30"
    start_date = @date_range.to_i.days.ago.beginning_of_day
    end_date = Time.current.end_of_day

    @metrics = {
      total_users: User.count,
      new_users: User.where(created_at: start_date..end_date).count,
      total_jobs: Job.count,
      active_jobs: Job.published.active.count,
      total_applications: Application.count,
      new_applications: Application.where(applied_at: start_date..end_date).count,
      total_companies: Company.approved.count,
      pending_companies: Company.pending.count
    }

    @user_registrations = User.where(created_at: start_date..end_date)
                              .group_by_day(:created_at)
                              .group(:role)
                              .count

    @job_postings = Job.where(created_at: start_date..end_date)
                       .group_by_day(:created_at)
                       .count

    @applications_trend = Application.where(applied_at: start_date..end_date)
                                     .group_by_day(:applied_at)
                                     .count

    @top_jobs = Job.published
                   .includes(:company)
                   .order(applications_count: :desc, views_count: :desc)
                   .limit(10)

    @application_status_distribution = Application.group(:status).count

    @industry_breakdown = Company.approved.group(:industry).count

    @employment_type_distribution = Job.published.group(:employment_type).count

    @conversion_metrics = calculate_conversion_metrics
  end

  private

  def calculate_conversion_metrics
    total_jobs = Job.published.count
    jobs_with_applications = Job.published.where("applications_count > 0").count

    total_applications = Application.count
    hired_applications = Application.where(status: "hired").count

    {
      jobs_with_applications_rate: total_jobs > 0 ? (jobs_with_applications.to_f / total_jobs * 100).round(2) : 0,
      application_to_hire_rate: total_applications > 0 ? (hired_applications.to_f / total_applications * 100).round(2) : 0,
      average_applications_per_job: total_jobs > 0 ? (total_applications.to_f / total_jobs).round(2) : 0
    }
  end
end
