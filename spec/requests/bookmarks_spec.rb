require 'rails_helper'

RSpec.describe "Bookmarks", type: :request do
  let(:user) { create(:user, :job_seeker) }
  let(:job) { create(:job) }
  let!(:bookmark) { create(:bookmark, user: user, job: job) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /index" do
    it "returns http success" do
      get bookmarks_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    it "deletes a bookmark and redirects" do
      expect {
        delete bookmark_path(bookmark)
      }.to change(Bookmark, :count).by(-1)

      expect(response).to redirect_to(bookmarks_path)
    end
  end
end
