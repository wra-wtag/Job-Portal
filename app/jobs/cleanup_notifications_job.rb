class CleanupNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    Notification.where("read_at IS NOT NULL AND read_at < ?", 30.days.ago).delete_all

    Notification.where("read_at IS NULL AND created_at < ?", 90.days.ago).delete_all
  end
end
