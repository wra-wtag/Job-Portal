class JobPolicy < ApplicationPolicy
    def index?
        true
    end

    def show?
        record.published? || can_manage?
    end

    def create?
        user.present? && user.recruiter? && user.can_post_jobs?
    end

    def edit?
        can_manage?
    end

    def update?
        can_manage?
    end

    def destroy?
        can_manage? || user&.admin?
    end

    def bookmark?
        user.present? && user.job_seeker?
    end

    def apply?
        user.present? && user.job_seeker? && record.active?
    end

    def toggle_status?
        can_manage?
    end

    private

    def can_manage?
        user.present? && (
            user.admin? ||
            (user.recruiter? && record.company.recruiters.include?(user))
        )
    end

    class Scope < Scope
        def resolve
            case user&.role
            when "admin"
                scope.all
            when "recruiter"
                scope.joins(:company).where(companies: { id: user.company_ids })
            else
                scope.published.active
            end
        end
    end
end
