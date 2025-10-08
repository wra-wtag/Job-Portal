class UpdateJobStatisticsJob < ApplicationJob
  queue_as :default

  def perform
    Job.published.where("expires_at < ?", Time.current).update_all(status: "closed")

    AdminMailer.daily_summary.deliver_now if admin_users_exist?
  end

  private

  def admin_users_exist?
    User.admins.any?
  end
end
