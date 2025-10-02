require 'rails_helper'

RSpec.describe "Jobs", type: :request do
  let(:user) { create(:user, :job_seeker) }
  let(:job) { create(:job, :published) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /index" do
    it "returns http success" do
      get jobs_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get job_path(job)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /apply" do
    it "returns http success" do
      get apply_job_path(job)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /bookmark" do
    it "bookmarks the job" do
      post bookmark_job_path(job)
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include("Bookmarked")
    end
  end

  describe "DELETE /unbookmark" do
    before { post bookmark_job_path(job) }

    it "removes the bookmark" do
      delete unbookmark_job_path(job)
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include("Job removed from bookmarks")
    end
  end
end
