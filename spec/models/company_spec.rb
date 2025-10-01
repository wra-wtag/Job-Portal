require 'rails_helper'

RSpec.describe Company, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_inclusion_of(:size).in_array(Company::SIZES).allow_blank }
    it 'validates the format of website with URI regex' do
      should allow_value('https://www.example.com').for(:website)
      should allow_value('http://example.org').for(:website)
      should_not allow_value('invalid-website').for(:website)
    end
  end

  describe "associations" do
    it { should belong_to(:approved_by).class_name('User').optional }
    it { should have_many(:recruiter_memberships).dependent(:destroy) }
    it { should have_many(:recruiters).through(:recruiter_memberships).source(:user) }
    it { should have_many(:jobs).dependent(:destroy) }
    it "has a logo attached" do
      expect(Company.new.logo).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(pending: 0, approved: 1, rejected: 2) }
  end

  describe "scopes" do
    before do
      create_list(:company, 2, :approved)
      create_list(:company, 3, :pending)
      create_list(:company, 1, :rejected)
    end
    it 'returns only approved companies' do
      expect(Company.approved.count).to eq(2)
    end
    it 'returns only pending companies' do
      expect(Company.pending.count).to eq(3)
    end
    it 'returns only rejected companies' do
      expect(Company.rejected.count).to eq(1)
    end
  end

  describe 'callbacks' do
    it 'generates slug from name' do
      company = create(:company, name: 'Test Company Inc')
      expect(company.slug).to eq('test-company-inc')
    end
  end

  describe "instance methods" do
    let(:company) { create(:company) }
    let(:admin_user) { create(:user, :admin) }

    describe "#approved?" do
      it "returns true if the company is approved" do
        company.update!(status: 'approved')
        expect(company.approved?).to be(true)
      end

      it "returns false if the company is not approved" do
        company.update!(status: 'pending')
        expect(company.approved?).to be(false)
      end
    end

    describe "#pending?" do
      it "returns true if the company is pending" do
        company.update!(status: 'pending')
        expect(company.pending?).to be(true)
      end

      it "returns false if the company is not pending" do
        company.update!(status: 'approved')
        expect(company.pending?).to be(false)
      end
    end

    describe "#rejected?" do
      it "returns true if the company is rejected" do
        company.update!(status: 'rejected')
        expect(company.rejected?).to be(true)
      end

      it "returns false if the company is not rejected" do
        company.update!(status: 'approved')
        expect(company.rejected?).to be(false)
      end
    end

    describe "#approve!" do
      it "updates the company status to approved and sets approved_by and approved_at" do
        expect { company.approve!(admin_user) }.to change { company.status }.to('approved')
        expect(company.approved_by).to eq(admin_user)
        expect(company.approved_at).to be_within(1.second).of(Time.current)
      end
    end

    describe "#reject!" do
      it "updates the company status to rejected" do
        expect { company.reject! }.to change { company.status }.to('rejected')
      end
    end
  end
end
