require "rails_helper"

RSpec.describe "Api::V1:Jobs", type: :request do
    let(:headers) { { "Content-Type" => "application/json" } }

    describe 'GET /api/v1/jobs' do
        let!(:company) { create(:company, :approved) }
        let!(:jobs) { create_list(:job, 15, :published, company: company) }

        it 'returns all published jobs' do
            get '/api/v1/jobs'

            expect(response).to have_http_status(:ok)
            expect(json_response[:success]).to be true
            expect(json_response[:data]).to be_an(Array)
            expect(json_response[:data].length).to eq(15)
        end

        it 'includes pagination metadata' do
            get '/api/v1/jobs?page=1&per_page=10'

            expect(response).to have_http_status(:ok)
            expect(json_response[:meta][:current_page]).to eq(1)
            expect(json_response[:meta][:total_pages]).to eq(2)
            expect(json_response[:meta][:total_count]).to eq(15)
            expect(json_response[:meta][:per_page]).to eq(10)
        end

        it 'includes company and skills data' do
            skill = create(:skill, name: 'Ruby')
            jobs.first.skills << skill

            get '/api/v1/jobs'

            first_job = json_response[:data].first
            expect(first_job[:company]).to be_present
            expect(first_job[:company][:name]).to eq(company.name)
        end

        context 'filtering' do
            let!(:remote_job) { create(:job, :published, company: company, is_remote: true) }
            let!(:sf_job) { create(:job, :published, company: company, location: 'San Francisco') }
            let!(:fulltime_job) { create(:job, :published, company: company, employment_type: 'full_time') }

            it 'filters by employment type' do
                get '/api/v1/jobs?employment_type=full_time'

                expect(response).to have_http_status(:ok)
                job_types = json_response[:data].map { |j| j[:employment_type] }.uniq
                expect(job_types).to eq([ 'full_time' ])
            end

            it 'filters by remote' do
                get '/api/v1/jobs?remote=true'

                expect(response).to have_http_status(:ok)
                remote_jobs = json_response[:data].all? { |j| j[:is_remote] }
                expect(remote_jobs).to be true
            end

            it 'filters by location' do
                get '/api/v1/jobs?location=San Francisco'

                expect(response).to have_http_status(:ok)
                locations = json_response[:data].map { |j| j[:location] }
                expect(locations).to all(match(/San Francisco/i))
            end

            it 'filters by salary range' do
                high_salary_job = create(:job, :published, company: company, salary_min: 100000, salary_max: 150000)

                get '/api/v1/jobs?salary_min=100000'

                expect(response).to have_http_status(:ok)
                salaries = json_response[:data].map { |j| j[:salary_min].to_f }
                expect(salaries).to all(be >= 100000.0)
            end
        end

        context 'searching' do
            let!(:ruby_job) { create(:job, :published, company: company, title: 'Ruby Developer') }
            let!(:python_job) { create(:job, :published, company: company, title: 'Python Developer') }

            it 'searches by job title' do
                get '/api/v1/jobs?search=Ruby'

                expect(response).to have_http_status(:ok)
                titles = json_response[:data].map { |j| j[:title] }
                expect(titles).to all(match(/Ruby/i))
            end

            it 'searches by company name' do
                get "/api/v1/jobs?search=#{company.name}"

                expect(response).to have_http_status(:ok)
                companies = json_response[:data].map { |j| j[:company][:name] }.uniq
                expect(companies).to include(company.name)
            end
        end

        context 'sorting' do
            before do
                jobs[0].update(published_at: 3.days.ago)
                jobs[1].update(published_at: 1.day.ago)
                jobs[2].update(published_at: 5.days.ago)
            end

            it 'sorts by newest' do
                get '/api/v1/jobs?sort=newest'

                expect(response).to have_http_status(:ok)
                dates = json_response[:data].map { |j| DateTime.parse(j[:published_at]) }
                expect(dates).to eq(dates.sort.reverse)
            end

            it 'sorts by oldest' do
                get '/api/v1/jobs?sort=oldest'

                expect(response).to have_http_status(:ok)
                dates = json_response[:data].map { |j| DateTime.parse(j[:published_at]) }
                expect(dates).to eq(dates.sort)
            end
        end
    end

    describe 'GET /api/v1/jobs/:id' do
        let(:company) { create(:company, :approved) }
        let(:job) { create(:job, :published, company: company) }
        let(:skill) { create(:skill, name: 'Ruby') }

        before { job.skills << skill }

        it 'returns job details' do
            get "/api/v1/jobs/#{job.id}"

            expect(response).to have_http_status(:ok)
            expect(json_response[:success]).to be true
            expect(json_response[:data][:id]).to eq(job.id)
            expect(json_response[:data][:title]).to eq(job.title)
        end

        it 'includes company data' do
            get "/api/v1/jobs/#{job.id}"

            company_data = json_response[:data][:company]
            expect(company_data[:id]).to eq(company.id)
            expect(company_data[:name]).to eq(company.name)
        end

        it 'includes skills' do
            get "/api/v1/jobs/#{job.id}"

            skills_data = json_response[:data][:skills]
            expect(skills_data).to be_an(Array)
            expect(skills_data.first[:name]).to eq('Ruby')
        end

        it 'increments view count' do
            expect {
                get "/api/v1/jobs/#{job.id}"
            }.to change { job.reload.views_count }.by(1)
        end

        it 'returns 404 for non-existent job' do
            get '/api/v1/jobs/99999'

            expect(response).to have_http_status(:not_found)
            expect(json_response[:error]).to be_present
        end
    end

    describe 'POST /api/v1/jobs/:id/apply' do
        let(:company) { create(:company, :approved) }
        let(:job) { create(:job, :published, company: company) }
        let(:job_seeker) { create(:user, :job_seeker) }
        let(:recruiter) { create(:user, :recruiter) }

        context 'as job seeker with valid data' do
            it 'creates an application' do
                expect {
                post "/api/v1/jobs/#{job.id}/apply",
                    params: { cover_letter: 'I am interested in this position' }.to_json,
                    headers: auth_headers(job_seeker).merge(headers)
                }.to change(Application, :count).by(1)

                expect(response).to have_http_status(:created)
                expect(json_response[:success]).to be true
            end

            it 'returns application data' do
                post "/api/v1/jobs/#{job.id}/apply",
                params: { cover_letter: 'I am interested in this position' }.to_json,
                headers: auth_headers(job_seeker).merge(headers)

                application_data = json_response[:data]
                expect(application_data[:status]).to eq('applied')
                expect(application_data[:cover_letter]).to eq('I am interested in this position')
                expect(application_data[:job][:id]).to eq(job.id)
            end

            it 'prevents duplicate applications' do
                create(:application, user: job_seeker, job: job)

                post "/api/v1/jobs/#{job.id}/apply",
                params: { cover_letter: 'Second application' }.to_json,
                headers: auth_headers(job_seeker).merge(headers)

                expect(response).to have_http_status(:unprocessable_content)
                expect(json_response[:error]).to match(/already applied/i)
            end
        end

        context 'as recruiter' do
            it 'returns forbidden error' do
                post "/api/v1/jobs/#{job.id}/apply",
                params: { cover_letter: 'Application' }.to_json,
                headers: auth_headers(recruiter).merge(headers)

                expect(response).to have_http_status(:forbidden)
                expect(json_response[:error]).to match(/only job seekers/i)
            end
        end

        context 'without authentication' do
            it 'returns unauthorized error' do
                post "/api/v1/jobs/#{job.id}/apply",
                params: { cover_letter: 'Application' }.to_json,
                headers: headers

                expect(response).to have_http_status(:unauthorized)
            end
        end
    end
end
