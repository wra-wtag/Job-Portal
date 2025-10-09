require "rails_helper"

RSpec.describe "Api::V1::Profiles", type: :request do
    let(:user) { create(:user, :job_seeker) }
    let(:headers) { { 'Content-Type' => 'application/json' } }

    describe 'GET /api/v1/profile' do
        it 'returns current user profile' do
            get '/api/v1/profile', headers: auth_headers(user)

            expect(response).to have_http_status(:ok)
            expect(json_response[:success]).to be true

            user_data = json_response[:data][:user]
            expect(user_data[:id]).to eq(user.id)
            expect(user_data[:email]).to eq(user.email)
            expect(user_data[:first_name]).to eq(user.first_name)
        end

        it 'includes applications count' do
            create_list(:application, 3, user: user)

            get '/api/v1/profile', headers: auth_headers(user)

            expect(json_response[:data][:applications_count]).to eq(3)
        end

        it 'includes bookmarks count' do
            create_list(:bookmark, 2, user: user)

            get '/api/v1/profile', headers: auth_headers(user)

            expect(json_response[:data][:bookmarks_count]).to eq(2)
        end

        it 'requires authentication' do
            get '/api/v1/profile'

            expect(response).to have_http_status(:unauthorized)
        end
    end

    describe 'PUT /api/v1/profile' do
        let(:update_params) do
        {
            user: {
                first_name: 'Updated',
                last_name: 'Name',
                username: 'Updated username',
                bio: 'Updated bio',
                location: 'New York, NY'
            }
        }
        end

        it 'updates user profile' do
            put '/api/v1/profile',
                params: update_params.to_json,
                headers: auth_headers(user).merge(headers)

            expect(response).to have_http_status(:ok)
            expect(json_response[:success]).to be true

            user.reload
            expect(user.first_name).to eq('Updated')
            expect(user.last_name).to eq('Name')
            expect(user.username).to eq("Updated username")
            expect(user.bio).to eq('Updated bio')
            expect(user.location).to eq('New York, NY')
        end

        it 'returns updated user data' do
            put '/api/v1/profile',
                params: update_params.to_json,
                headers: auth_headers(user).merge(headers)

            user_data = json_response[:data][:user]
            expect(user_data[:first_name]).to eq('Updated')
            expect(user_data[:bio]).to eq('Updated bio')
        end

        it 'returns error for invalid data' do
            invalid_params = { user: { username: '' } }

            put '/api/v1/profile',
                params: invalid_params.to_json,
                headers: auth_headers(user).merge(headers)

            expect(response).to have_http_status(:unprocessable_content)
            expect(json_response[:errors]).to be_present
        end
    end
end
