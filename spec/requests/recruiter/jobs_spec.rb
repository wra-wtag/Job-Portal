# spec/requests/recruiter/jobs_spec.rb
require 'rails_helper'

RSpec.describe "Recruiter::Jobs", type: :request do
  let(:setup) { create_recruiter_with_company }
  let(:recruiter) { setup[:recruiter] }
  let(:company) { setup[:company] }
  let(:job) { create(:job, company: company, posted_by_user: recruiter) }

  before do
    sign_in recruiter, scope: :user
    recruiter.recruiter_memberships.first.update!(status: :approved)
  end

  describe "GET /index" do
    it "returns http success" do
      get recruiter_jobs_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get recruiter_job_path(job)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_recruiter_job_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a job" do
      expect {
        post recruiter_jobs_path, params: {
          job: attributes_for(:job).merge(company_id: company.id)
        }
      }.to change(Job, :count).by(1)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_recruiter_job_path(job)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates job" do
      patch recruiter_job_path(job), params: { job: { title: 'Updated' } }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /destroy" do
    it "deletes job" do
      job # create job
      expect {
        delete recruiter_job_path(job)
      }.to change(Job, :count).by(-1)
    end
  end

  describe "PATCH /toggle_status" do
    it "toggles status" do
      patch toggle_status_recruiter_job_path(job)
      expect(response).to have_http_status(:redirect)
    end
  end
end
