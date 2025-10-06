require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }
  let!(:notification) { create(:notification, :unread, user: user) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /index" do
    it "returns a successful response" do
      get notifications_path
      expect(response).to have_http_status(:success)
    end
    it "marks all notifications as read and redirects when param is present" do
      get notifications_path, params: { mark_all_read: "true" }
      expect(response).to redirect_to(notifications_path)
      expect(user.notifications.unread.count).to eq(0)
    end
  end

  describe "GET /show" do
    it "marks the notification as read and redirects" do
      get notification_path(notification)

      expect(notification.reload.read?).to be true
      expect(response).to redirect_to(notification_redirect_path(notification))
    end
  end

  describe "DELETE /destroy" do
    it "deletes the notification and redirects" do
      expect {
        delete notification_path(notification)
      }.to change(Notification, :count).by(-1)

      expect(response).to redirect_to(notifications_path)
    end
  end

  describe "POST /mark_as_read" do
    it "marks a notification as read and returns success for JSON requests" do
      post mark_as_read_notification_path(notification), params: { format: :json }

      expect(response).to have_http_status(:success)
      expect(notification.reload.read?).to be true
    end
  end
  describe "POST /mark_all_as_read" do
    let!(:another_notification) { create(:notification, :unread, user: user) }

    it "marks all notifications as read and returns success for JSON requests" do
      expect(user.notifications.unread.count).to eq(2)
      post mark_all_as_read_notifications_path, params: { format: :json }

      expect(response).to have_http_status(:success)
      expect(user.notifications.unread.count).to eq(0)
    end
  end
  private

  def notification_redirect_path(notification)
    case notification.kind
    when "new_job_application"
      recruiter_applications_path
    when "application_update"
      applications_path
    when "job_recommendation"
      jobs_path
    when "recruiter_approved"
      recruiter_dashboard_path
    else
      root_path
    end
  end
end
