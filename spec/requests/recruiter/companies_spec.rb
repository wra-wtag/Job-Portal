require 'rails_helper'

RSpec.describe "Recruiter::Companies", type: :request do
  let(:setup) { create_recruiter_with_company }
  let(:recruiter) { setup[:recruiter] }
  let(:company) { setup[:company] }

  before do
    sign_in recruiter, scope: :user
    recruiter.recruiter_memberships.first.update!(status: :approved)
  end

  describe "GET /show" do
    it "returns http success" do
      get recruiter_company_path(company)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_recruiter_company_path(company)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates company" do
      patch recruiter_company_path(company), params: { company: { name: 'Updated Name' } }
      expect(response).to have_http_status(:redirect)
    end
  end
end
