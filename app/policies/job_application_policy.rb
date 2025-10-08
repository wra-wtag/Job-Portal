class JobApplicationPolicy < ApplicationPolicy
    def index?
        user.present?
    end

    def show?
        user.present? && (
            user.admin? || record.user == user || (user.recruiter? && record.job.company.recruiters.include?(user))
        )
    end

    def create?
        user.present? && user.job_seeker?
    end

    def update?
        user.present? && (
            user.admin? || (user.recruiter? && record.job.company.recruiters.include?(user))
        )
    end

    def withdraw?
        user.present? && record.user == user && record.can_withdraw?
    end

    class Scope < Scope
        def resolve
            case user&.role
            when "admin"
                scope.all
            when "recruiter"
                scope.joins(job: :company).where(jobs: { companies: { id: user.company_ids } })
            when "job_seeker"
                scope.where(user: user)
            else
                scope.none
            end
        end
    end
end
