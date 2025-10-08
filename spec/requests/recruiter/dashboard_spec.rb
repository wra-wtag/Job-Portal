require 'rails_helper'

RSpec.describe "Recruiter::Dashboard", type: :request do
  let(:setup) { create_recruiter_with_company }
  let(:recruiter) { setup[:recruiter] }

  before do
    sign_in recruiter, scope: :user
    recruiter.recruiter_memberships.first.update!(status: :approved)
  end

  describe "GET /index" do
    it "returns http success" do
      get recruiter_dashboard_path
      expect(response).to have_http_status(:success)
    end
  end
end
