class JobRecommendation < ApplicationRecord
  belongs_to :user

  validates :algorithm_version, :generated_at, presence: true
  validates :payload, presence: true

  store_accessor :payload, :job_ids, :total_jobs, :skills_matched, :user_location, :user_skills

  scope :pending, -> { where(sent_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :scheduled_for_today, -> { where(scheduled_for: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :ensure_payload_structure

  def sent?    = sent_at.present?
  def pending? = sent_at.blank?

  def recommended_jobs
    return [] unless payload && payload["job_ids"].present?
    Job.where(id: payload["job_ids"]).active.limit(10)
  end

  def mark_as_sent! = update!(sent_at: Time.current)

  def jobs_count     = (total_jobs || Array(job_ids).count || 0)
  def includes_job?(job_id) = Array(job_ids).include?(job_id.to_i)
  def matched_skills = (skills_matched || [])

  private

  def ensure_payload_structure
    return if payload.nil?

    self.payload = {} unless payload.is_a?(Hash)
    self.job_ids ||= []
  end
end
