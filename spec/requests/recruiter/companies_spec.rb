require 'rails_helper'

RSpec.describe "Recruiter::Companies", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/recruiter/companies/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/recruiter/companies/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/recruiter/companies/update"
      expect(response).to have_http_status(:success)
    end
  end
end
