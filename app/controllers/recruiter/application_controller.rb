class Recruiter::ApplicationController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_recruiter!
    before_action :ensure_approved_membership!
    layout 'recruiter'

    private

    def ensure_recruiter!
        redirect_to root_path, alert: 'Access denied.' unless current_user.recruiter?
    end

    def ensure_approved_membership!
        unless current_user.recruiter_memberships.approved.joins(:company).where(companies: { status: 'approved' }).any?
            if current_user.recruiter_memberships.pending.any?
                redirect_to recruiter_pending_path, alert: 'Your recruiter request is still pending approval.'
            else
                redirect_to recruiter_onboarding_path, alert: 'You need to be part of an approved company to access recruiter features.'
            end
        end
    end

    def current_company
        @current_company ||= current_user.recruiter_memberships.approved.joins(:company).where(companies: { status: "approved" }).first&.company
    end
    helper_method :current_company
end
