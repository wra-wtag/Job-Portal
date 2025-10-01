class Application < ApplicationRecord
  belongs_to :job, counter_cache: :applications_count
  belongs_to :user

  enum :status, { applied: 0, viewed: 1, shortlisted: 2, rejected: 3, hired: 4, withdrawn: 5 }

  validates :job_id, uniqueness: { scope: :user_id, message: "You have already applied for this job" }

  has_one_attached :resume

  scope :recent, -> { order(applied_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :pending_review, -> { where(status: [ :applied, :viewed ]) }

  before_create :set_applied_at

  def status_humanized
    status.humanize
  end

  def can_withdraw?
    [ :applied, :viewed ].include?(status.to_sym)
  end

  def withdraw!
    update!(status: :withdrawn)
  end

  def set_applied_at
    self.applied_at = Time.current
  end

  def self.policy_class
    JobApplicationPolicy
  end
end
