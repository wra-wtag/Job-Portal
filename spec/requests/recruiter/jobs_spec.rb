require 'rails_helper'

RSpec.describe "Recruiter::Jobs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/recruiter/jobs/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/recruiter/jobs/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/recruiter/jobs/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/recruiter/jobs/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/recruiter/jobs/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/recruiter/jobs/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/recruiter/jobs/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /toggle_status" do
    it "returns http success" do
      get "/recruiter/jobs/toggle_status"
      expect(response).to have_http_status(:success)
    end
  end
end
