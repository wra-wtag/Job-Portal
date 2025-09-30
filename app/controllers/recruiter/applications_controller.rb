class Recruiter::ApplicationsController < Recruiter::ApplicationController
  before_action :set_application, only: [ :show, :update ]

  def index
    @applications = Application.joins(:job)
                              .includes(:user, job: :company)
                              .where(jobs: { company: current_company })
                              .order(applied_at: :desc)
                              .page(params[:page]).per(15)
    @applications = @applications.where(status: params[:status]) if params[:status].present?
    @applications = @applications.where(job_id: params[:job_id]) if params[:job_id].present?
    @stats = {
      total: Application.joins(:job).where(jobs: { company: current_company }).count,
      applied: Application.joins(:job).where(jobs: { company: current_company }, applications: { status: "applied" }).count,
      viewed: Application.joins(:job).where(jobs: { company: current_company }, applications: { status: "viewed" }).count,
      shortlisted: Application.joins(:job).where(jobs: { company: current_company }, applications: { status: "shortlisted" }).count,
      rejected: Application.joins(:job).where(jobs: { company: current_company }, applications: { status: "rejected" }).count,
      hired: Application.joins(:job).where(jobs: { company: current_company }, applications: { status: "hired" }).count
    }
    @company_jobs = current_company.jobs.published.order(:title).pluck(:title, :id)
  end

  def show
    authorize @application
    if @application.status == "applied"
      @application.update!(status: "viewed")

      Notification.create!(
        user: @application.user,
        kind: "application_update",
        title: "Application Viewed",
        content: "Your application for #{@application.job.title} has been reviewed by #{current_company.name}"
      )
    end
  end

  def update
    authorize @application

    old_status = @application.status
    new_status = params.dig(:application, :status)

    if @application.update(status: new_status)
      Notification.create!(
        user: @application.user,
        kind: "application_update",
        title: "Application Status Update",
        content: application_status_message(new_status, @application.job.title)
      )

      JobApplicationMailer.application_status_update(@application).deliver_later

      redirect_to recruiter_application_path(@application),
                  notice: "Application status updated to #{new_status.humanize}!"
    else
      redirect_to recruiter_application_path(@application),
                  alert: "Failed to update application status."
    end
  end

  private

  def set_application
    @application = Application.joins(:job)
                             .where(jobs: { company: current_company })
                             .find(params[:id])
  end

  def application_status_message(status, job_title)
    case status
    when "shortlisted"
      "Great news! You've been shortlisted for #{job_title}. We'll be in touch soon."
    when "rejected"
      "Thank you for your interest in #{job_title}. Unfortunately, we've decided to move forward with other candidates."
    when "hired"
      "Congratulations! You've been selected for the #{job_title} position. We'll contact you with next steps."
    else
      "Your application status for #{job_title} has been updated."
    end
  end
end
