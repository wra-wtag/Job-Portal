class Recruiter::TeamController < Recruiter::ApplicationController
  before_action :ensure_manager!
  before_action :set_company

  def index
    @pending_requests = @company.recruiter_memberships.pending.includes(:user)
    @current_recruiters = @company.recruiter_memberships.approved.includes(:user)
  end

  def approve_request
    @request = @company.recruiter_memberships.pending.find(params[:id])
    @request.approve!

    Notification.create!(
      user: @request.user,
      kind: "recruiter_approved",
      title: "Recruiter Request Approved!",
      content: "You've been approved as a recruiter for #{@company.name}"
    )

    redirect_to recruiter_team_index_path, notice: "Recruiter request approved!"
  end

  def reject_request
    @request = @company.recruiter_memberships.pending.find(params[:id])
    @request.reject!

    Notification.create!(
      user: @request.user,
      kind: "recruiter_rejected",
      title: "Recruiter Request Declined",
      content: "Your request to join #{@company.name} as a recruiter has been declined"
    )

    redirect_to recruiter_team_index_path, notice: "Recruiter request rejected."
  end

  def remove_recruiter
    @membership = @company.recruiter_memberships.approved.find(params[:id])

    if @membership.user == current_user
      redirect_to recruiter_team_index_path, alert: "You cannot remove yourself."
      return
    end

    @membership.destroy

    # Notification.create!(
    #   user: @membership.user,
    #   kind: "recruiter_removed",
    #   title: "Removed from Company",
    #   content: "You've been removed as a recruiter from #{@company.name}"
    # )

    redirect_to recruiter_team_index_path, notice: "Recruiter removed successfully."
  end

  private

  def ensure_manager!
    redirect_to recruiter_dashboard_path unless current_user.can_manage_company?(current_company)
  end

  def set_company
    @company = current_company
  end
end
