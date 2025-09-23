class Bookmark < ApplicationRecord
  # Validations
  validates :user_id, uniqueness: { scope: :job_id }

  # Associations
  belongs_to :user
  belongs_to :job

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
end
