class RecruiterMembership < ApplicationRecord
  belongs_to :user
  belongs_to :company

  enum :role, { standard: 0, manager: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :user_id, uniqueness: { scope: :company_id }

  scope :primary, -> { where(is_primary: true) }

  def can_manage_recruiters?
    manager? && approved?
  end

  def approve!
    update!(status: :approved)
  end

  def reject!
    update!(status: :rejected)
  end
end
