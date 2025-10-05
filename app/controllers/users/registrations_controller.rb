class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, except: [ :new, :create ]
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :username, :role, :bio, :location
    ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :username, :bio, :location, :resume, notification_preferences: {}
    ])
  end

  def after_sign_up_path_for(resource)
    if resource.confirmed?
      if resource.job_seeker?
        profile_setup_path
      elsif resource.recruiter?
        recruiter_onboarding_path
      else
        root_path
      end
    else
      flash[:notice] = "Please check your email to confirm your account."
      new_user_session_path
    end
  end

  def after_update_path_for(resource)
    if resource.recruiter? && resource.companies.empty?
      new_company_path
    else
      profile_path
    end
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
