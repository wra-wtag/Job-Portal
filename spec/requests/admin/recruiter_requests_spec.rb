require 'rails_helper'

RSpec.describe "Admin::RecruiterRequests", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/recruiter_requests/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/recruiter_requests/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /approve" do
    it "returns http success" do
      get "/admin/recruiter_requests/approve"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /reject" do
    it "returns http success" do
      get "/admin/recruiter_requests/reject"
      expect(response).to have_http_status(:success)
    end
  end
end
