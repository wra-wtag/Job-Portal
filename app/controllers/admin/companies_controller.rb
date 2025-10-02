class Admin::CompaniesController < Admin::ApplicationController
  before_action :set_company, only: [ :show, :edit, :update, :destroy, :approve, :reject ]

  def index
    @companies = Company.includes(:recruiters, :approved_by)
                        .order(created_at: :desc)
                        .page(params[:page])

    @companies = @companies.where(status: params[:status].to_sym) if params[:status].present?

    @pending_count = Company.pending.count
    @approved_count = Company.approved.count
    @rejected_count = Company.rejected.count
  end

  def show
    @recruiters = @company.recruiters
    @jobs = @company.jobs.includes(:posted_by_user)
    @applications_count = Application.joins(:job).where(jobs: { company: @company }).count
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to admin_company_path(@company), notice: "Company updated successfully!"
    else
      render :edit
    end
  end

  def destroy
    @company.destroy
    redirect_to admin_companies_path, notice: "Company deleted successfully!"
  end

  def approve
    if @company.approve!(current_user)
      CompanyApprovalMailer.approved(@company).deliver_later

      # @company.recruiters.each do |recruiter|
      #   Notification.create!(
      #     user: recruiter,
      #     kind: :company_approved,
      #     title: "Company Approved!",
      #     content: "Your company #{@company.name} has been approved and you can now start posting jobs."
      #   )
      # end

      redirect_to admin_company_path(@company), notice: "Company approved successfully!"
    else
      redirect_to admin_company_path(@company), alert: "Failed to approve company."
    end
  end

  def reject
    if @company.reject!
      CompanyApprovalMailer.rejected(@company).deliver_later

      # @company.recruiters.each do |recruiter|
      #   Notification.create!(
      #     user: recruiter,
      #     kind: :company_rejected,
      #     title: "Company Application Rejected",
      #     content: "Unfortunately, your company application for #{@company.name} has been rejected. Please contact support for more information."
      #   )
      # end

      redirect_to admin_company_path(@company), notice: "Company rejected successfully!"
    else
      redirect_to admin_company_path(@company), alert: "Failed to reject company."
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :description, :location, :website, :industry, :size, :logo)
  end
end
