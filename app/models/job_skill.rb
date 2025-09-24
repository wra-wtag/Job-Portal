class JobSkill < ApplicationRecord
  validates :job_id, uniqueness: { scope: :skill_id }

  belongs_to :job
  belongs_to :skill

  scope :required, -> { where(required: true) }
  scope :optional, -> { where(required: false) }
end
