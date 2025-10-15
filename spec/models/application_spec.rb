require "rails_helper"

RSpec.describe Application, type: :model do
  describe "associations" do
    it { should belong_to(:job).counter_cache(:applications_count) }
    it { should belong_to(:user) }
    it { is_expected.to respond_to(:resume) }
  end

  describe "validations" do
    subject { build(:application) }

    it "validates uniqueness of job_id scoped to user_id" do
      application = create(:application)
      duplicate = build(:application, job: application.job, user: application.user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:job_id]).to include("You have already applied for this job")
    end
  end

  describe "callbacks" do
    it "sets applied_at before create" do
      application = build(:application, applied_at: nil)
      application.save!
      expect(application.applied_at).to be_present
    end
  end

  describe "instance methods" do
    let(:application) { create(:application, :applied) }

    it "status predicates work correctly" do
      expect(application.applied?).to be true

      application.update!(status: :viewed)
      expect(application.viewed?).to be true

      application.update!(status: :shortlisted)
      expect(application.shortlisted?).to be true

      application.update!(status: :rejected)
      expect(application.rejected?).to be true

      application.update!(status: :hired)
      expect(application.hired?).to be true

      application.update!(status: :withdrawn)
      expect(application.withdrawn?).to be true
    end

    it "#can_withdraw? returns true if status is applied or viewed" do
      application.update!(status: :applied)
      expect(application.can_withdraw?).to be true

      application.update!(status: :viewed)
      expect(application.can_withdraw?).to be true

      application.update!(status: :shortlisted)
      expect(application.can_withdraw?).to be false
    end

    it "#withdraw! updates status to withdrawn" do
      application.update!(status: :applied)
      application.withdraw!
      expect(application.status).to eq("withdrawn")
    end
  end
end
