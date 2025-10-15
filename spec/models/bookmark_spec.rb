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
end
