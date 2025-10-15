require "rails_helper"

RSpec.describe JobRecommendation, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:job_recommendation) }

    it { should validate_presence_of(:payload) }
    it { should validate_presence_of(:algorithm_version) }
    it { should validate_presence_of(:generated_at) }
  end

  describe "scopes" do
    let!(:pending_rec) { create(:job_recommendation, :pending) }
    let!(:sent_rec) { create(:job_recommendation, :sent) }
    let!(:today_rec) { create(:job_recommendation, scheduled_for: Date.current) }
    let!(:tomorrow_rec) { create(:job_recommendation, scheduled_for: Date.tomorrow) }

    it ".pending returns recommendations without sent_at" do
      expect(JobRecommendation.pending).to include(pending_rec)
      expect(JobRecommendation.pending).not_to include(sent_rec)
    end

    it ".sent returns recommendations with sent_at" do
      expect(JobRecommendation.sent).to include(sent_rec)
      expect(JobRecommendation.sent).not_to include(pending_rec)
    end

    it ".scheduled_for_today returns recommendations scheduled for today" do
      expect(JobRecommendation.scheduled_for_today).to include(today_rec)
      expect(JobRecommendation.scheduled_for_today).not_to include(tomorrow_rec)
    end
  end

  describe "instance methods" do
    let(:job1) { create(:job, :published) }
    let(:job2) { create(:job, :published) }
    let(:job3) { create(:job, :closed) } # should not be returned by recommended_jobs
    let(:recommendation) { create(:job_recommendation, payload: { 'job_ids' => [ job1.id, job2.id, job3.id ] }) }

    it "#sent? returns true if sent_at is present" do
      recommendation.mark_as_sent!
      expect(recommendation.sent?).to be true
    end

    it "#pending? returns true if sent_at is nil" do
      expect(recommendation.pending?).to be true
    end

    it "#recommended_jobs returns only active jobs" do
      recommended = recommendation.recommended_jobs
      expect(recommended).to include(job1, job2)
      expect(recommended).not_to include(job3)
    end

    it "#mark_as_sent! sets sent_at" do
      expect { recommendation.mark_as_sent! }.to change { recommendation.sent_at }.from(nil)
    end
  end
end
