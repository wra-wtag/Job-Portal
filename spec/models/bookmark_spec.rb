require "rails_helper"

RSpec.describe Bookmark, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:job) }
  end

  describe "validations" do
    subject { build(:bookmark) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:job_id) }
  end

  describe "scopes" do
    let!(:older_bookmark) { create(:bookmark, created_at: 2.days.ago) }
    let!(:recent_bookmark) { create(:bookmark, created_at: 1.day.ago) }

    it ".recent returns bookmarks ordered by created_at descending" do
      expect(Bookmark.recent).to eq([ recent_bookmark, older_bookmark ])
    end
  end
end
