require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_inclusion_of(:role).in_array(User::ROLES) }
  end

  describe "associations" do
    it { should have_many(:applications).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
    it { should have_many(:user_skills).dependent(:destroy) }
    it { should have_many(:bookmarks).dependent(:destroy) }
    it { should have_many(:bookmarked_jobs).through(:bookmarks).source(:job) }
    it { should have_many(:skills).through(:user_skills) }
    it { should have_many(:job_recommendations).dependent(:destroy) }
    it { should have_many(:recruiter_memberships).dependent(:destroy) }
    it { should have_many(:companies).through(:recruiter_memberships) }
    it { should have_many(:posted_jobs).dependent(:destroy) }
    it { should have_many(:posted_jobs).class_name('Job').with_foreign_key('posted_by_user_id') }
    it { should have_many(:approved_companies).class_name('Company').with_foreign_key('approved_by_id') }
    it 'has a resume attached' do
      expect(User.new.resume).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  describe "scopes" do
    let!(:job_seeker) { create(:user, :job_seeker) }
    let!(:recruiter) { create(:user, :recruiter) }
    let!(:admin) { create(:user, :admin) }

    it "returns job seekers" do
      expect(User.job_seekers).to include(job_seeker)
      expect(User.job_seekers).not_to include(recruiter, admin)
    end

    it "returns recruiters" do
      expect(User.recruiters).to include(recruiter)
      expect(User.recruiters).not_to include(job_seeker, admin)
    end
  end

  describe "methods" do
    let(:user) { create(:user, first_name: "John", last_name: "Doe") }

    it "returns full name" do
      expect(user.full_name).to eq("John Doe")
    end

    it "checks role methods" do
      job_seeker = create(:user, :job_seeker)
      recruiter = create(:user, :recruiter)
      admin = create(:user, :admin)

      expect(job_seeker).to be_job_seeker
      expect(recruiter).to be_recruiter
      expect(admin).to be_admin
    end
  end
end
