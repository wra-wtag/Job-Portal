class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pundit::Authorization

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :username, :role
    ])
  end

  def handle_unauthorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  # check if current user is admin
  def ensure_admin!
    redirect_to root_path unless current_user&.admin?
  end

  # check if current user is recruiter
  def ensure_recruiter!
    redirect_to root_path unless current_user&.recruiter?
  end

  # checks if a user has approved company
  def ensure_approved_company!
    if current_user.recruiter? && !current_user.can_post_jobs?
      redirect_to company_pending_approval_path
    end
  end
end
