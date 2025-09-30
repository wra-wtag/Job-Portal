require 'rails_helper'

RSpec.describe "Recruiter::Applications", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/recruiter/applications/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/recruiter/applications/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/recruiter/applications/update"
      expect(response).to have_http_status(:success)
    end
  end
end
