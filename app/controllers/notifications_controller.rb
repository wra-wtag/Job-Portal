class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [ :show, :destroy ]

  def index
    @notifications = current_user.notifications
                                 .order(created_at: :desc)
                                 .page(params[:page]).per(10)

    if params[:mark_all_read] == "true"
      current_user.notifications.unread.update_all(read_at: Time.current)
      redirect_to notifications_path, notice: "All notifications marked as read"
    end

    @unread_count = current_user.notifications.unread.count
  end

  def show
    @notification.mark_as_read! if @notification.unread?
    redirect_to notification_redirect_path(@notification)
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, notice: "Notification deleted"
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { success: true } }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "All notifications marked as read" }
      format.json { render json: { success: true } }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  def notification_redirect_path(notification)
    case notification.kind
    when "new_job_application"
      recruiter_applications_path
    when "application_update"
      applications_path
    when "job_recommendation"
      jobs_path
    when "recruiter_approved"
      recruiter_dashboard_path
    else
      root_path
    end
  end
end
