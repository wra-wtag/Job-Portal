class Notification < ApplicationRecord
  belongs_to :user
  enum :kind, { new_job_application: 0, application_update: 1, job_recommendation: 2, system_announcement: 3 }
  
  validates :title, presence: true

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
