class RecruiterMembership < ApplicationRecord
  belongs_to :user
  belongs_to :company

  enum :role, { standard: 0, manager: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :user_id, uniqueness: { scope: :company_id }

  scope :managers, -> { where(role: :manager) }
  scope :standard, -> { where(role: :standard) }
  scope :primary, -> { where(is_primary: true) }
  scope :pending, -> { where(status: :pending) }
  scope :approved, -> { where(status: :approved) }
  scope :rejected, -> { where(status: :rejected) }

  def can_manage_recruiters?
    manager? && approved?
  end

  def approve!
    update!(status: :approved)
  end

  def reject!
    update!(status: :rejected)
  end

  after_update :send_approval_email, if: :saved_change_to_status

  private

  def send_approval_email
    if status_previously_changed? && approved?
      RecruiterMailer.request_approved(self).deliver_later
    end
  end
end
