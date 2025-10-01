class Admin::RecruiterRequestsController < Admin::ApplicationController
  before_action :set_request, only: [ :show, :approve, :reject ]

  def index
    @requests = RecruiterMembership.pending
                                  .includes(:user, :company)
                                  .order(created_at: :desc)
                                  .page(params[:page])

    @stats = {
      total_pending: RecruiterMembership.pending.count,
      total_approved: RecruiterMembership.approved.count,
      total_rejected: RecruiterMembership.rejected.count
    }
  end

  def show
    @company_managers = @request.company.recruiter_memberships.approved.managers.includes(:user)
  end

  def approve
    @request.approve!

    Notification.create!(
      user: @request.user,
      kind: :recruiter_approved,
      title: "Recruiter Request Approved!",
      content: "Admin has approved your request to join #{@request.company.name} as a recruiter"
    )

    @request.company.recruiter_memberships.approved.managers.each do |manager_membership|
      Notification.create!(
        user: manager_membership.user,
        kind: :admin_approved_recruiter,
        title: "New Team Member Added",
        content: "Admin approved #{@request.user.full_name} to join your company as a recruiter"
      )
    end

    redirect_to admin_recruiter_request_path(@request), notice: "Recruiter request approved by admin!"
  end

  def reject
    @request.reject!

    Notification.create!(
      user: @request.user,
      kind: :recruiter_rejected,
      title: "Recruiter Request Declined",
      content: "Your request to join #{@request.company.name} has been declined by admin"
    )

    redirect_to admin_recruiter_request_path(@request), notice: "Recruiter request rejected."
  end

  private

  def set_request
    @request = RecruiterMembership.find(params[:id])
  end
end
