class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_recruiter!, except: [ :pending_approval ]
  skip_before_action :authenticate_user!, only: [ :pending_approval ]
  before_action :redirect_to_onboarding, only: [ :pending_approval ]

  def new
    @company = Company.new
    authorize @company
  end

  def create
    @company = Company.new(company_params)
    authorize @company

    if @company.save
      RecruiterMembership.create!(
        user: current_user,
        company: @company,
        role: :manager,
        status: :pending,
        is_primary: true,
        title: "Founder"
      )

      redirect_to company_pending_approval_path, notice: "Company application submitted successfully! Please wait for admin approval."
    else
      render :new
    end
  end

  def edit
    @company = current_user.companies.find(params[:id])
    authorize @company
  end

  def update
    @company = current_user.companies.find(params[:id])
    authorize @company

    if @company.update(company_params)
      redirect_to recruiter_dashboard_path, notice: "Company updated successfully!"
    else
      render :edit
    end
  end

  def pending_approval
    if user_signed_in? && current_user.recruiter?
      @companies = current_user.companies.pending
      @pending_memberships = current_user.recruiter_memberships.pending

      if current_user.can_post_jobs?
        redirect_to recruiter_dashboard_path
      end
    else
      redirect_to root_path, alert: "Access denied."
    end
  end

  private

  def ensure_recruiter!
    redirect_to root_path unless current_user.recruiter?
  end

  def company_params
    params.require(:company).permit(:name, :description, :location, :website, :industry, :size, :logo)
  end

  def redirect_to_onboarding
    unless current_user.has_any_recruiter_requests?
      redirect_to recruiter_onboarding_path
    end
  end
end
