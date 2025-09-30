class RecruiterMembership < ApplicationRecord
  belongs_to :user
  belongs_to :company
  ROLES = %w[standard manager].freeze
  STATUSES = %w[pending approved rejected].freeze

  validates :role, inclusion: { in: ROLES }
  validates :status, inclusion: { in: STATUSES }
  validates :user_id, uniqueness: { scope: :company_id }

  scope :managers, -> { where(role: "manager") }
  scope :standard, -> { where(role: "standard") }
  scope :primary, -> { where(is_primary: true) }
  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }

  def manager?
    role == "manager"
  end

  def standard?
    role == "standard"
  end

  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end

  def can_manage_recruiters?
    manager? && approved?
  end

  def approve!
    update!(status: "approved")
  end

  def reject!
    update!(status: "rejected")
  end
end
