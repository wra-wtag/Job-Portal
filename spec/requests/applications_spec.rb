require 'rails_helper'

RSpec.describe "Applications", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/applications/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/applications/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /withdraw" do
    it "returns http success" do
      get "/applications/withdraw"
      expect(response).to have_http_status(:success)
    end
  end

end
