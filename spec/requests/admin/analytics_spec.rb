require 'rails_helper'

RSpec.describe "Admin::Analytics", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "GET /index" do
    context "when user is not logged in" do
      it "redirects to login page" do
        get admin_analytics_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
