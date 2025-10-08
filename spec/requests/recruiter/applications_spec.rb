require 'rails_helper'

RSpec.describe "Recruiter::Applications", type: :request do
  let(:setup) { create_recruiter_with_company }
  let(:recruiter) { setup[:recruiter] }
  let(:company) { setup[:company] }
  let(:job) { create(:job, :published, company: company, posted_by_user: recruiter) }
  let(:application) { create(:application, job: job) }

  before do
    sign_in recruiter, scope: :user
    recruiter.recruiter_memberships.first.update!(status: :approved)
  end

  describe "GET /index" do
    it "returns http success" do
      get recruiter_applications_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get recruiter_application_path(application)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates application status" do
      patch recruiter_application_path(application), params: { application: { status: 'applied' } }
      expect(response).to have_http_status(:redirect)
      expect(application.reload.status).to eq('applied')
    end
  end
end
