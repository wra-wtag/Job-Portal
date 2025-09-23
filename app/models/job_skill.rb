class JobSkill < ApplicationRecord
  # Validations
  validates :job_id, uniqueness: { scope: :skill_id }

  # Associations
  belongs_to :job
  belongs_to :skill

  # Scopes
  scope :required, -> { where(required: true) }
  scope :optional, -> { where(required: false) }
end
