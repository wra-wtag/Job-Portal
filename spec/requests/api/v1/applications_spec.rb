require 'rails_helper'

RSpec.describe 'Api::V1::Applications', type: :request do
  let(:job_seeker) { create(:user, :job_seeker) }
  let(:recruiter) { create(:user, :recruiter) }

  describe 'GET /api/v1/applications' do
    let!(:applications) { create_list(:application, 5, user: job_seeker) }
    let!(:other_applications) { create_list(:application, 3) }

    it 'returns current user applications only' do
      get '/api/v1/applications', headers: auth_headers(job_seeker)

      expect(response).to have_http_status(:ok)
      expect(json_response[:data].length).to eq(5)

      application_ids = json_response[:data].map { |a| a[:id] }
      expect(application_ids).to match_array(applications.map(&:id))
    end

    it 'includes job and company data' do
      get '/api/v1/applications', headers: auth_headers(job_seeker)

      first_app = json_response[:data].first
      expect(first_app[:job]).to be_present
      expect(first_app[:job][:title]).to be_present
    end

    context 'filtering by status' do
      before do
        applications[0].update(status: 'applied')
        applications[1].update(status: 'shortlisted')
        applications[2].update(status: 'rejected')
      end

      it 'filters by status' do
        get '/api/v1/applications?status=shortlisted', headers: auth_headers(job_seeker)

        expect(response).to have_http_status(:ok)
        statuses = json_response[:data].map { |a| a[:status] }.uniq
        expect(statuses).to eq([ 'shortlisted' ])
      end
    end

    it 'requires job seeker role' do
      get '/api/v1/applications', headers: auth_headers(recruiter)

      expect(response).to have_http_status(:forbidden)
      expect(json_response[:error]).to match(/only job seekers/i)
    end

    it 'requires authentication' do
      get '/api/v1/applications'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/applications/:id' do
    let(:application) { create(:application, user: job_seeker) }
    let(:other_application) { create(:application) }

    it 'returns application details' do
      get "/api/v1/applications/#{application.id}", headers: auth_headers(job_seeker)

      expect(response).to have_http_status(:ok)
      expect(json_response[:data][:id]).to eq(application.id)
      expect(json_response[:data][:status]).to eq(application.status)
    end

    it 'returns 404 for other user application' do
      get "/api/v1/applications/#{other_application.id}", headers: auth_headers(job_seeker)

      expect(response).to have_http_status(:not_found)
    end
  end
end
