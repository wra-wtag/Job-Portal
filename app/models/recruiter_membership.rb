class RecruiterMembership < ApplicationRecord
  belongs_to :user
  belongs_to :company
  ROLES = %w[standard manager].freeze
  
  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :company_id }

  scope :managers, -> { where(role: 'manager') }
  scope :standard, -> { where(role: 'standard') }
  scope :primary, -> { where(is_primary: true) }

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
