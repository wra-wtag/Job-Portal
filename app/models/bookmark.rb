class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :job

  validates :user_id, uniqueness: { scope: :job_id }

  scope :recent, -> { order(created_at: :desc) }
end
