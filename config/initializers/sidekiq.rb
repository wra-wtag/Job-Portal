require "sidekiq"
require "sidekiq-cron"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  config.on(:startup) do
    Sidekiq::Cron::Job.load_from_hash({
      "weekly_recommendations" => {
        "cron" => "0 9 * * 0",
        "class" => "WeeklyRecommendationsJob"
      },
      "cleanup_old_notifications" => {
        "cron" => "0 2 * * *",
        "class" => "CleanupNotificationJob"
      },
      "update_job_statistics" => {
        "cron" => "0 1 * * *",
        "class" => "UpdateJobStatisticsJob"
      }
    })
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end
