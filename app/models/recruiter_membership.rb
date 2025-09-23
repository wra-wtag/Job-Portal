class RecruiterMembership < ApplicationRecord
  ROLES = %w[standard manager].freeze

  # Validations
  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :company_id }

  # Associations
  belongs_to :user
  belongs_to :company

  # Scopes
  scope :managers, -> { where(role: 'manager') }
  scope :standard, -> { where(role: 'standard') }
  scope :primary, -> { where(is_primary: true) }

  # Methods
  def manager?
    role == 'manager'
  end

  def standard?
    role == 'standard'
  end

  def can_manage_recruiters?
    manager?
  end
end
