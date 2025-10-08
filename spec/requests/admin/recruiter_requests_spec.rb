require 'rails_helper'

RSpec.describe "Admin::RecruiterRequests", type: :request do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user, scope: :user
  end


  describe "GET /index" do
    it "returns http success" do
      get admin_companies_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    let(:company) { create(:company) }

    it "returns http success" do
      get admin_company_path(company)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /approve" do
    let(:company) { create(:company, status: 'pending') }

    it "approves the company" do
      patch approve_admin_company_path(company)
      expect(response).to have_http_status(:redirect)
      expect(company.reload.status).to eq('approved')
    end
  end

  describe "PATCH /reject" do
    let(:company) { create(:company, status: 'pending') }

    it "rejects the company" do
      patch reject_admin_company_path(company)
      expect(response).to have_http_status(:redirect)
      expect(company.reload.status).to eq('rejected')
    end
  end
end
