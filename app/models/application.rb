class Application < ApplicationRecord
  def self.policy_class
    JobApplicationPolicy
  end
  STATUSES = %w[applied viewed shortlisted rejected hired withdrawn].freeze

  # Validations
  validates :status, inclusion: { in: STATUSES }
  validates :job_id, uniqueness: { scope: :user_id, message: 'You have already applied for this job' }

  # Associations
  belongs_to :job, counter_cache: :applications_count
  belongs_to :user
  has_one :company, through: :job

  # ActiveStorage
  has_one_attached :resume

  # Scopes
  scope :recent, -> { order(applied_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :pending_review, -> { where(status: ['applied', 'viewed']) }

  # Callbacks
  before_create :set_applied_at

  # Methods
  def applied?
    status == 'applied'
  end

  def viewed?
    status == 'viewed'
  end

  def shortlisted?
    status == 'shortlisted'
  end

  def rejected?
    status == 'rejected'
  end

  def hired?
    status == 'hired'
  end

  def withdrawn?
    status == 'withdrawn'
  end

  def status_humanized
    status.humanize
  end

  def can_withdraw?
    %w[applied viewed].include?(status)
  end

  def withdraw!
    update!(status: 'withdrawn')
  end

  private

  def set_applied_at
    self.applied_at = Time.current
  end
end
