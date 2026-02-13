class CompanyPolicy < ApplicationPolicy
    def show?
        true
    end

    def create?
        user.present? & user.recruiter?
    end

    def edit?
        user.present? && (
            user.admin? ||
            (user.recruiter? && user.companies.include?(record))
        )
    end

    def update?
        edit?
    end

    def destroy?
        user.present? && user.admin?
    end

    def approve?
        user.present? && user.admin?
    end

    def reject?
        approve?
    end

    class Scope < Scope
        def resolve
            case user&.role
            when "admin"
                scope.all
            when "recruiter"
                user.companies
            else
                scope.approved
            end
        end
    end
end
