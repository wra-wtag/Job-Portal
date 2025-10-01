require "rails_helper"

RSpec.describe Job, type: :model do
  describe "associations" do
    it { should belong_to(:company) }
    it { should belong_to(:posted_by_user).class_name("User") }
    it { should have_many(:applications).dependent(:destroy) }
    it { should have_many(:applicants).through(:applications).source(:user) }
    it { should have_many(:bookmarks).dependent(:destroy) }
    it { should have_many(:job_skills).dependent(:destroy) }
    it { should have_many(:skills).through(:job_skills) }
  end

  describe "validations" do
    subject { build(:job) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should allow_value(nil).for(:salary_min) }
    it { should allow_value(nil).for(:salary_max) }
    it { should validate_numericality_of(:salary_min).is_greater_than(0).allow_nil }
    it { should validate_numericality_of(:salary_max).is_greater_than(0).allow_nil }

    it "validates salary_max > salary_min" do
      job = build(:job, salary_min: 50_000, salary_max: 40_000)
      expect(job).not_to be_valid
      expect(job.errors[:salary_max]).to include("must be greater than minimum salary")
    end
  end

  describe "enums" do
    it { should define_enum_for(:employment_type).with_values(full_time: 0, part_time: 1, contract: 2, internship: 3, temporary: 4) }
    it { should define_enum_for(:status).with_values(draft: 0, published: 1, closed: 2) }
  end

  describe "scopes" do
    let!(:draft_job) { create(:job, status: "draft") }
    let!(:published_job) { create(:job, :published) }
    let!(:expired_job) { create(:job, :published, :expired) }

    it ".published returns only published jobs" do
      expect(Job.published).to contain_exactly(published_job, expired_job)
    end

    it ".active returns only published and not expired jobs" do
      expect(Job.active).to contain_exactly(published_job)
    end

    it ".by_employment_type returns jobs of a given type" do
      type = draft_job.employment_type
      expect(Job.by_employment_type(type)).to include(draft_job)
    end

    it ".with_salary_range returns jobs within salary range" do
      job = create(:job, salary_min: 40_000, salary_max: 80_000)
      expect(Job.with_salary_range(40_000, 80_000)).to include(job)
    end

    it ".recent orders jobs by created_at desc" do
      expect(Job.recent.first).to eq(expired_job)
    end
  end

  describe "callbacks" do
    it "sets published_at when status changes to published" do
      job = create(:job, status: "draft")
      job.update!(status: "published")
      expect(job.published_at).to be_present
    end
  end

  describe "instance methods" do
    let(:job) { create(:job, salary_min: 40_000, salary_max: 80_000, status: "published", expires_at: 2.days.from_now) }

    it "#published? returns true when status is published" do
      expect(job.published?).to be true
    end

    it "#expired? returns false if not expired" do
      expect(job.expired?).to be false
    end

    it "#expired? returns true if expires_at passed" do
      job.update!(expires_at: 1.day.ago)
      expect(job.expired?).to be true
    end

    it "#active? returns true if published and not expired" do
      expect(job.active?).to be true
    end

    it "#increment_views! increments views_count" do
      expect { job.increment_views! }.to change { job.views_count }.by(1)
    end

    it "#employment_type_humanized returns humanized string" do
      expect(job.employment_type_humanized).to eq(job.employment_type.humanize)
    end

    it "#salary_range returns formatted string" do
      expect(job.salary_range).to eq("USD 40000 - 80000")
    end
  end
end
