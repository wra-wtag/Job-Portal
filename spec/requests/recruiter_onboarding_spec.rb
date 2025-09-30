require 'rails_helper'

RSpec.describe "RecruiterOnboardings", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/recruiter_onboarding/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create_company" do
    it "returns http success" do
      get "/recruiter_onboarding/create_company"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /join_company" do
    it "returns http success" do
      get "/recruiter_onboarding/join_company"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /submit_request" do
    it "returns http success" do
      get "/recruiter_onboarding/submit_request"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /pending" do
    it "returns http success" do
      get "/recruiter_onboarding/pending"
      expect(response).to have_http_status(:success)
    end
  end
end
