require 'rails_helper'

RSpec.describe "Recruiter::Teams", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/recruiter/team/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /approve_request" do
    it "returns http success" do
      get "/recruiter/team/approve_request"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /reject_request" do
    it "returns http success" do
      get "/recruiter/team/reject_request"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /remove_recruiter" do
    it "returns http success" do
      get "/recruiter/team/remove_recruiter"
      expect(response).to have_http_status(:success)
    end
  end

end
