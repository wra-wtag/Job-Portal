class Application < ApplicationRecord
  belongs_to :job, counter_cache: :applications_count
  belongs_to :user

  enum :status, { applied: 0, viewed: 1, shortlisted: 2, rejected: 3, hired: 4, withdrawn: 5 }

  validates :job_id, uniqueness: { scope: :user_id, message: "You have already applied for this job" }
  validates :status, inclusion: { in: statuses.keys }

  has_one_attached :resume
  validates :resume, content_type: [ "application/pdf" ], size: { less_than: 5.megabytes, message: "must be a PDF and smaller than 5 MB" }

  scope :pending_review, -> { where(status: [ :applied, :viewed ]) }

  before_create :set_applied_at

  def can_withdraw?
    [ :applied, :viewed ].include?(status.to_sym)
  end

  def withdraw!
    raise StandardError, "Application cannot be withdrawn" unless can_withdraw?

    update!(status: :withdrawn)
  end

  private

  def set_applied_at
    self.applied_at = Time.current
  end
end
