class Notification < ApplicationRecord
  belongs_to :user

  KINDS = %w[new_job_application application_update job_recommendation system_announcement].freeze

  # validations
  validates :kind, inclusion: { in: KINDS }
  validates :title, presence: true

  # scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_kind, ->(kind) { where(kind: kind) }

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
