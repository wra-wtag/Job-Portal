class RecruiterOnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_recruiter!
  before_action :check_if_already_approved!, only: [ :index ]
  layout "application"

  def index
    @has_pending = current_user.recruiter_memberships.pending.any? || current_user.companies.pending.any?
    @companies = Company.approved.order(:name)
  end

  def create_company
    redirect_to new_company_path
  end

  def join_company
    @company = Company.approved.find(params[:company_id])
    @membership_request = current_user.recruiter_memberships.build(company: @company)
  end

  def submit_request
    @company = Company.approved.find(params[:company_id])
    existing_request = current_user.recruiter_memberships.find_by(company: @company)

    if existing_request
      redirect_to recruiter_onboarding_path, alert: "You already have a request for this company."
      return
    end

    @membership_request = current_user.recruiter_memberships.build(
      company: @company,
      role: "standard",
      status: "pending",
      title: params[:title],
      contact_info: {
        message: params[:message],
        experience: params[:experience]
      }
    )

    if @membership_request.save
      # @company.recruiter_memberships.approved.managers.each do |manager_membership|
      #   Notification.create!(
      #     user: manager_membership.user,
      #     kind: "recruiter_request",
      #     title: "New Recruiter Request",
      #     content: "#{current_user.full_name} wants to join #{@company.name} as a recruiter"
      #   )
      # end

      redirect_to recruiter_pending_path, notice: "Your request has been sent to the company managers!"
    else
      render :join_company
    end
  end

  def pending
    @pending_companies = current_user.companies.pending.includes(:approved_by)
    @pending_memberships = current_user.recruiter_memberships.pending.includes(:company)
    @approved_memberships = current_user.recruiter_memberships.approved.includes(:company)

    if @approved_memberships.any? { |m| m.company.approved? }
      redirect_to recruiter_dashboard_path
      return
    end

    if @pending_companies.empty? && @pending_memberships.empty?
      redirect_to recruiter_onboarding_path
      nil
    end
  end

  private

  def ensure_recruiter!
    redirect_to root_path unless current_user.recruiter?
  end

  def check_if_already_approved!
    return if action_name == "pending"

    if current_user.can_post_jobs?
      redirect_to recruiter_dashboard_path
    end
  end
end
