class JobRecommendation < ApplicationRecord
  validates :payload, :algorithm_version, :generated_at, presence: true

  belongs_to :user

  scope :pending, -> { where(sent_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :scheduled_for_today, -> { where(scheduled_for: Date.current.beginning_of_day..Date.current.end_of_day) }

  def sent?
    sent_at.present?
  end

  def pending?
    sent_at.blank?
  end

  def recommended_jobs
    return [] unless payload["job_ids"].present?

    Job.where(id: payload["job_ids"]).active.limit(10)
  end

  def mark_as_sent!
    update!(sent_at: Time.current)
  end
end
