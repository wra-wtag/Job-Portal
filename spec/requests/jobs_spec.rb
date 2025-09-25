require 'rails_helper'

RSpec.describe "Jobs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/jobs/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/jobs/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /apply" do
    it "returns http success" do
      get "/jobs/apply"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /submit_application" do
    it "returns http success" do
      get "/jobs/submit_application"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /bookmark" do
    it "returns http success" do
      get "/jobs/bookmark"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /unbookmark" do
    it "returns http success" do
      get "/jobs/unbookmark"
      expect(response).to have_http_status(:success)
    end
  end

end
