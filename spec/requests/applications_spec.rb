require 'rails_helper'

RSpec.describe "Applications", type: :request do
  let(:user) { create(:user, :job_seeker) }
  let(:job) { create(:job) }
  let!(:application) { create(:application, user: user, job: job) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /index" do
    it "returns http success" do
      get applications_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get application_path(application)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /withdraw" do
    it "returns http success" do
      patch withdraw_application_path(application)
      expect(response).to redirect_to(applications_path)
    end
  end
end
