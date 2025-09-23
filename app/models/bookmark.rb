class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :job
  
  #validations
  validates :user_id, uniqueness: { scope: :job_id }

  # scopes
  scope :recent, -> { order(created_at: :desc) }
end
