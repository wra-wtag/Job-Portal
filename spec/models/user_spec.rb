require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
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

  describe "enums" do
    it { should define_enum_for(:role).with_values(job_seeker: 0, recruiter: 1, admin: 2) }
  end

  describe "scopes" do
    let!(:job_seeker) { create(:user, role: :job_seeker) }
    let!(:recruiter) { create(:user, role: :recruiter) }
    let!(:admin) { create(:user, role: :admin) }

    it "returns job seekers" do
      expect(User.job_seeker).to include(job_seeker)
      expect(User.job_seeker).not_to include(recruiter, admin)
    end

    it "returns recruiters" do
      expect(User.recruiter).to include(recruiter)
      expect(User.recruiter).not_to include(job_seeker, admin)
    end

    it "returns admins" do
      expect(User.admin).to include(admin)
      expect(User.admin).not_to include(job_seeker, recruiter)
    end
  end

  describe "instance methods" do
    let(:user) { create(:user, first_name: "John", last_name: "Doe") }

    describe "#full_name" do
      it "returns full name" do
        expect(user.full_name).to eq("John Doe")
      end
    end

    describe "role helper methods" do
      it "checks role methods" do
        job_seeker = create(:user, role: :job_seeker)
        recruiter = create(:user, role: :recruiter)
        admin = create(:user, role: :admin)

        expect(job_seeker).to be_job_seeker
        expect(recruiter).to be_recruiter
        expect(admin).to be_admin
      end
    end
  end
end
