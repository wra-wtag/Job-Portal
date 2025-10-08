class ApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_job_seeker!
  before_action :set_application, only: [ :show, :withdraw ]

  def index
    @applications = policy_scope(Application)
                   .includes(:job, job: :company)
                   .order(applied_at: :desc)
                   .page(params[:page])
                   .per(10)
    @applications = @applications.where(status: params[:status]) if params[:status].present?

    @stats = {
      total: current_user.applications.count,
      applied: current_user.applications.where(status: "applied").count,
      viewed: current_user.applications.where(status: "viewed").count,
      shortlisted: current_user.applications.where(status: "shortlisted").count,
      rejected: current_user.applications.where(status: "rejected").count,
      hired: current_user.applications.where(status: "hired").count
    }
  end

  def show
    authorize @application

    current_user.notifications
                .where(kind: "application_update")
                .where("content LIKE ?", "%#{@application.job.title}")
                .unread
                .update_all(read_at: Time.current)
  end

  def withdraw
    authorize @application

    if @application.can_withdraw?
      @application.withdraw!

      @application.job.company.recruiters.each do |recruiter|
        Notification.create!(
          user: recruiter,
          kind: "application_update",
          title: "Application Withdrawn",
          content: "#{current_user.full_name} withdraw their application for #{@application.job.title}"
        )
      end
      redirect_to applications_path, notice: "Application withdrawn successfully."
    else
      redirect_to application_path(@application), alert: "Cannot withdraw this application."
    end
  end

  private

  def set_application
    @application = current_user.applications.find(params[:id])
  end

  def ensure_job_seeker!
    redirect_to root_path, alert: "Access denied." unless current_user.job_seeker?
  end
end
