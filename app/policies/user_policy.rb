class UserPolicy < ApplicationPolicy
    def show?
        user.present? && (user == record || user.admin?)
    end

    def edit?
        user.present? && (user == record || user.admin?)
    end

    def update?
        edit?
    end

    def destroy?
        user.present? && user.admin? && user != record
    end

    def setup?
        user.present? && user == record
    end

    class Scope < Scope
        def resolve
            if user.admin?
                scope.all
            else
                scope.where(id: user.id)
            end
        end
    end
end
