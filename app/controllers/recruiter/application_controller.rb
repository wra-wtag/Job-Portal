class Recruiter::ApplicationController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_recruiter!
    before_action :check_recruiter_status!
    layout "recruiter"

    private

    def ensure_recruiter!
        redirect_to root_path, alert: "Access denied." unless current_user.recruiter?
    end

    def check_recruiter_status!
        approved_memberships = current_user.recruiter_memberships
                                           .approved
                                           .joins(:company)
                                           .where(companies: { status: "approved" })

        if approved_memberships.empty?
            has_pending_requests = current_user.recruiter_memberships.pending.any?
            has_pending_companies = current_user.companies.pending.any?

            if has_pending_requests || has_pending_companies
                redirect_to recruiter_pending_path, alert: "Your request is still pending approval."
            else
                redirect_to recruiter_onboarding_path, alert: "Please create a company or request to join an existing one."
            end
        end
    end

    def current_company
        @current_company ||= current_user.recruiter_memberships.approved.joins(:company).where(companies: { status: "approved" }).first&.company
    end
    helper_method :current_company
end
