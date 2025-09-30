class UserSkill < ApplicationRecord
  validates :user_id, uniqueness: { scope: :skill_id }
  validates :experience_years, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user
  belongs_to :skill

  scope :by_experience, ->(years) { where("experience_years >= ?", years) }
end
