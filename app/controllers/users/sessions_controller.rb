# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  protected

  def after_sign_up_path_for(resource)
    case resource.role
    when "admin"
      admin_dashboard_path
    when "recruiter"
      if resource.companies.approved.any?
        recruiter_dashboard_path
      else
        company_pending_approval_path
      end
    when "job_seeker"
      jobs_path
    else
      root_path
    end
  end

  def after_sign_out_path_for(resource)
    root_path
  end
end
