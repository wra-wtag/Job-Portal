class Notification < ApplicationRecord
  KINDS = %w[new_job_application application_update job_recommendation system_announcement].freeze

  # Validations
  validates :kind, inclusion: { in: KINDS }
  validates :title, presence: true

  # Associations
  belongs_to :user

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_kind, ->(kind) { where(kind: kind) }

  # Methods
  def read?
    read_at.present?
  end

  def unread?
    read_at.blank?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end
end
