require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_inclusion_of(:role).in_array(User::ROLES) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it { should have_many(:applications).dependent(:destroy) }
    it { should have_many(:bookmarks).dependent(:destroy) }
    it { should have_many(:bookmarked_jobs).through(:bookmarks) }
    it { should have_many(:notifications).dependent(:destroy) }
    it { should have_many(:user_skills).dependent(:destroy) }
    it { should have_many(:skills).through(:user_skills) }
    it { should have_many(:recruiter_memberships).dependent(:destroy) }
    it { should have_many(:companies).through(:recruiter_memberships) }
    it { should have_many(:posted_jobs).dependent(:destroy) }
    it { should have_many(:approved_companies) }
    
    # Test ActiveStorage attachment separately
    it 'has one attached resume' do
      user = create(:user)
      expect(user.resume).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  describe 'scopes' do
    let!(:job_seeker) { create(:user, :job_seeker) }
    let!(:recruiter) { create(:user, :recruiter) }
    let!(:admin) { create(:user, :admin) }

    it 'returns job seekers' do
      expect(User.job_seekers).to include(job_seeker)
      expect(User.job_seekers).not_to include(recruiter, admin)
    end

    it 'returns recruiters' do
      expect(User.recruiters).to include(recruiter)
      expect(User.recruiters).not_to include(job_seeker, admin)
    end

    it 'returns admins' do
      expect(User.admins).to include(admin)
      expect(User.admins).not_to include(job_seeker, recruiter)
    end
  end

  describe 'methods' do
    let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }

    it 'returns full name' do
      expect(user.full_name).to eq('John Doe')
    end

    it 'checks role methods' do
      job_seeker = create(:user, :job_seeker)
      recruiter = create(:user, :recruiter)
      admin = create(:user, :admin)

      expect(job_seeker).to be_job_seeker
      expect(recruiter).to be_recruiter
      expect(admin).to be_admin
    end

    it 'generates username automatically' do
      user = build(:user, first_name: 'John', last_name: 'Doe', username: nil)
      user.save!
      expect(user.username).to start_with('johndoe')
    end

    it 'handles duplicate usernames' do
      create(:user, username: 'johndoe')
      user = build(:user, first_name: 'John', last_name: 'Doe', username: nil)
      user.save!
      expect(user.username).to eq('johndoe1')
    end
  end

  describe 'recruiter methods' do
    let(:admin) { create(:user, :admin) }
    let(:recruiter) { create(:user, :recruiter) }
    let(:approved_company) { create(:company, :approved) }
    let(:pending_company) { create(:company, status: 'pending') }

    it 'returns primary company' do
      membership = create(:recruiter_membership, :primary, user: recruiter, company: approved_company)
      expect(recruiter.primary_company).to eq(approved_company)
    end

    it 'checks if can post jobs' do
      create(:recruiter_membership, user: recruiter, company: approved_company)
      expect(recruiter.can_post_jobs?).to be true
    end

    it 'cannot post jobs without approved company' do
      create(:recruiter_membership, user: recruiter, company: pending_company)
      expect(recruiter.can_post_jobs?).to be false
    end
  end
end
