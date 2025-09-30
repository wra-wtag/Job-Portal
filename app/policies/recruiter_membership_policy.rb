class RecruiterMembershipPolicy < ApplicationPolicy
  def approve_request?
    user.present? && (
      user.admin? ||
      (user.recruiter? && user.can_manage_company?(record.company))
    )
  end

  def reject_request?
    approve_request?
  end

  def remove_recruiter?
    approve_request? && record.user != user
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.recruiter?
        managed_company_ids = user.recruiter_memberships.approved.managers.pluck(:company_id)
        scope.where(company_id: managed_company_ids)
      else
        scope.none
      end
    end
  end
end
