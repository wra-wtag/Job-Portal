require "rails_helper"

RSpec.describe "Api::V1::Companies", type: :request do
    describe 'GET /api/v1/companies' do
        let!(:approved_companies) { create_list(:company, 10, :approved) }
        let!(:pending_company) { create(:company, status: 'pending') }

        it 'returns only approved companies' do
            get '/api/v1/companies'

            expect(response).to have_http_status(:ok)
            expect(json_response[:success]).to be true
            expect(json_response[:data].length).to eq(10)
        end

        it 'includes pagination metadata' do
            get '/api/v1/companies?page=1&per_page=5'

            expect(json_response[:meta][:current_page]).to eq(1)
            expect(json_response[:meta][:total_pages]).to eq(2)
            expect(json_response[:meta][:total_count]).to eq(10)
        end

        context 'filtering' do
            let!(:tech_company) { create(:company, :approved, industry: 'Technology') }
            let!(:healthcare_company) { create(:company, :approved, industry: 'Healthcare') }

            it 'filters by industry' do
                get '/api/v1/companies?industry=Technology'

                expect(response).to have_http_status(:ok)
                industries = json_response[:data].map { |c| c[:industry] }.uniq
                expect(industries).to eq([ 'Technology' ])
            end

            it 'searches by name' do
                named_company = create(:company, :approved, name: 'Unique Company Name')

                get '/api/v1/companies?search=Unique'

                expect(response).to have_http_status(:ok)
                names = json_response[:data].map { |c| c[:name] }
                expect(names).to include('Unique Company Name')
            end
        end
    end

    describe 'GET /api/v1/companies/:id' do
        let(:company) { create(:company, :approved) }
        let!(:jobs) { create_list(:job, 3, :published, company: company) }

        it 'returns company details' do
            get "/api/v1/companies/#{company.id}"

            expect(response).to have_http_status(:ok)
            expect(json_response[:success]).to be true

            company_data = json_response[:data][:company]
            expect(company_data[:id]).to eq(company.id)
            expect(company_data[:name]).to eq(company.name)
        end

        it 'includes company jobs' do
            get "/api/v1/companies/#{company.id}"

            jobs_data = json_response[:data][:jobs]
            expect(jobs_data).to be_an(Array)
            expect(jobs_data.length).to eq(3)
        end

        it 'returns 404 for non-existent company' do
            get '/api/v1/companies/99999'

            expect(response).to have_http_status(:not_found)
        end
    end
end
