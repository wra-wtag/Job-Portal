class UserSkill < ApplicationRecord
  validates :user_id, uniqueness: { scope: :skill_id }
  validates :years_of_experience, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user
  belongs_to :skill

  scope :by_experience, ->(years) { where("years_of_experience >= ?", years) }
end
