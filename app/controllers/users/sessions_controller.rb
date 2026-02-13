class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  protected

  def after_sign_in_path_for(resource)
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

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
