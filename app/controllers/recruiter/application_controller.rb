class Recruiter::ApplicationController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_recruiter!
    before_action :ensure_approved_company!
    layout 'recruiter'

    private

    def ensure_recruiter!
        redirect_to root_path, alert: 'Access denied.' unless current_user.recruiter?
    end

    def ensure_approved_company!
        if current_user.recruiter? && !current_user.can_post_jobs?
            redirect_to company_pending_approval_path, alert: 'Your company needs approval before you can access recruiter features.'
        end
    end

    def current_company
        @current_company ||= current_user.primary_company || current_user.companies.approved.first
    end
    helper_method :current_company
end
