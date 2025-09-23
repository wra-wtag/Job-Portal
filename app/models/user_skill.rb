class UserSkill < ApplicationRecord
  # Validations
  validates :user_id, uniqueness: { scope: :skill_id }
  validates :experience_years, numericality: { greater_than_or_equal_to: 0 }

  # Associations
  belongs_to :user
  belongs_to :skill

  # Scopes
  scope :by_experience, ->(years) { where('experience_years >= ?', years) }
end
