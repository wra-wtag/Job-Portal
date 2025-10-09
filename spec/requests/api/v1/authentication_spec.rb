require "rails_helper"

RSpec.describe "Api::V1::Authentication", type: :request do
    let(:headers) { { "Content-Type" => "application/json" } }

    describe "POST /api/v1/auth/signup" do
        let(:valid_attributes) do
            {
                user: {
                    email: "newuser@example.com",
                    password: "password",
                    password_confirmation: "password",
                    first_name: "John",
                    last_name: "Doe",
                    username: "john.doe",
                    role: "job_seeker"
                }
            }
        end

        context "with valid parameters" do
            it "creates a new user" do
                expect {
                    post "/api/v1/auth/signup", params: valid_attributes.to_json, headers: headers
                }.to change(User, :count).by(1)
            end

            it "returns a token" do
                post "/api/v1/auth/signup", params: valid_attributes.to_json, headers: headers

                expect(response).to have_http_status(:created)
                expect(json_response[:success]).to be true
                expect(json_response[:data][:token]).to be_present
            end

            it "returns user data" do
                post "/api/v1/auth/signup", params: valid_attributes.to_json, headers: headers

                user_data = json_response[:data][:user]
                expect(user_data[:email]).to eq("newuser@example.com")
                expect(user_data[:first_name]).to eq("John")
                expect(user_data[:last_name]).to eq("Doe")
                expect(user_data[:role]).to eq("job_seeker")
            end
        end

        context "with invalid parameters" do
            it "returns error for missing email" do
                invalid_attributes = valid_attributes.deep_dup
                invalid_attributes[:user].delete(:email)

                post "/api/v1/auth/signup", params: invalid_attributes.to_json, headers: headers

                expect(response).to have_http_status(:unprocessable_content)
                expect(json_response[:errors]).to be_present
            end

            it "returns error for mismatched passwords" do
                invalid_attributes = valid_attributes.deep_dup
                invalid_attributes[:user][:password_confirmation] = "different"

                post "/api/v1/auth/signup", params: invalid_attributes.to_json, headers: headers

                expect(response).to have_http_status(:unprocessable_content)
                expect(json_response[:errors]).to include(/Password confirmation doesn't match Password/)
            end

            it "returns error for duplicate email" do
                create(:user, email: "newuser@example.com")

                post "/api/v1/auth/signup", params: valid_attributes.to_json, headers: headers

                expect(response).to have_http_status(:unprocessable_content)
                expect(json_response[:errors]).to include(/Email has already been taken/)
            end
        end
    end

    describe "POST /api/v1/auth/login" do
        let!(:user) { create(:user, :job_seeker, email: "test@example.com", password: "password") }

        context "with valid credentials" do
            it "returns a token" do
                post "/api/v1/auth/login", params: {
                    user: { email: "test@example.com", password: "password" }
                }.to_json, headers: headers

                expect(response).to have_http_status(:ok)
                expect(json_response[:success]).to be true
                expect(json_response[:data][:token]).to be_present
            end

            it "returns user data" do
                post "/api/v1/auth/login", params: {
                    user: { email: "test@example.com", password: "password" }
                }.to_json, headers: headers

                user_data = json_response[:data][:user]
                expect(user_data[:email]).to eq("test@example.com")
                expect(user_data[:id]).to eq(user.id)
            end
        end

        context "with invalid credentials" do
            it "returns error for wrong password" do
                post "/api/v1/auth/login", params: {
                    user: { email: "test@example.com", password: "wrongpassword" }
                }.to_json, headers: headers

                expect(response).to have_http_status(:unauthorized)
                expect(json_response[:error]).to eq("Invalid email or password")
            end

            it "returns error for non-existent user" do
                post "/api/v1/auth/login", params: {
                    user: { email: "nonexistent@example.com", password: "password" }
                }.to_json, headers: headers

                expect(response).to have_http_status(:unauthorized)
                expect(json_response[:error]).to eq("Invalid email or password")
            end
        end
    end

    describe "GET /api/v1/auth/me" do
        let(:user) { create(:user, :job_seeker) }

        context "with valid token" do
            it "returns current user data" do
                get "/api/v1/auth/me", headers: auth_headers(user)

                expect(response).to have_http_status(:ok)
                expect(json_response[:success]).to be true
                expect(json_response[:data][:user][:id]).to eq(user.id)
                expect(json_response[:data][:user][:email]).to eq(user.email)
            end
        end

        context "without token" do
            it "returns unauthorized error" do
                get "/api/v1/auth/me"

                expect(response).to have_http_status(:unauthorized)
                expect(json_response[:error]).to eq("Unauthorized access")
            end
        end

        context "without invalid token" do
            it "returns unauthorized error" do
                get "/api/v1/auth/me", headers: { "Authorization" => "Bearer invalid_token" }

                expect(response).to have_http_status(:unauthorized)
                expect(json_response[:error]).to eq("Unauthorized access")
            end
        end
    end

    describe "DELETE /api/v1/auth/logout" do
        let(:user) { create(:user, :job_seeker) }

        it "returns success message" do
            delete "/api/v1/auth/logout", headers: auth_headers(user)

            expect(response).to have_http_status(:ok)
            expect(json_response[:success]).to be true
            expect(json_response[:data][:message]).to eq("Logged out successfully")
        end
    end
end
