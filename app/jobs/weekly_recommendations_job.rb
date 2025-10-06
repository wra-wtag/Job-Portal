class WeeklyRecommendationsJob < ApplicationJob
  queue_as :default

  def perform
    # Run every Sunday at 9 AM
    User.job_seeker
        .where(weekly_recommendations_enabled: true)
        .where(email_verified: true)
        .find_each(batch_size: 100) do |user|
      # Check if user hasn't received recommendations in the last 7 days
      last_recommendation = user.job_recommendations.order(created_at: :desc).first

      if last_recommendation.nil? || last_recommendation.created_at < 7.days.ago
        JobRecommendationJob.perform_later(user.id)
      end
    end
  end
end
