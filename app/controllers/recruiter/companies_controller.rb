class Recruiter::CompaniesController < ApplicationController
  before_action :set_company, only: [ :show, :edit, :update ]

  def show
    authorize @company
  end

  def edit
    authorize @company

    unless current_user.can_manage_company?(@company)
      redirect_to recruiter_dashboard_path, alert: "Only company managers can edit the company profile."
    end
  end

  def update
    authorize @company

    unless current_user.can_manage_company?(@company)
      redirect_to recruiter_dashboard_path, alert: "Only company managers can edit the company profile."
      return
    end

    if @company.update(company_params)
      redirect_to recruiter_dashboard_path, notice: "Company updated successfully!"
    else
      render :edit
    end
  end

  private

  def set_company
    @company = current_user.companies.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :description, :location, :website, :industry, :size, :logo)
  end
end
