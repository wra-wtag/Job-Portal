require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    # Provide a subject with required attributes for uniqueness validation
    subject { build(:company) }
    
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_inclusion_of(:status).in_array(Company::STATUSES) }
  end

  describe 'associations' do
    it { should have_many(:recruiter_memberships).dependent(:destroy) }
    it { should have_many(:jobs).dependent(:destroy) }
    it { should belong_to(:approved_by).optional }
    it { should have_one_attached(:logo) }
  end

  describe 'scopes' do
    let!(:pending_company) { create(:company, status: 'pending') }
    let!(:approved_company) { create(:company, :approved) }
    let!(:rejected_company) { create(:company, :rejected) }

    it 'returns approved companies' do
      expect(Company.approved).to include(approved_company)
      expect(Company.approved).not_to include(pending_company, rejected_company)
    end

    it 'returns pending companies' do
      expect(Company.pending).to include(pending_company)
      expect(Company.pending).not_to include(approved_company, rejected_company)
    end
  end

  describe 'callbacks' do
    it 'generates slug from name' do
      company = build(:company, name: 'Test Company Inc')
      company.save!
      expect(company.slug).to eq('test-company-inc')
    end

    it 'updates slug when name changes' do
      company = create(:company, name: 'Original Name')
      company.update!(name: 'New Company Name')
      expect(company.slug).to eq('new-company-name')
    end
  end

  describe 'methods' do
    let(:admin) { create(:user, :admin) }
    
    it 'approves company' do
      company = create(:company, status: 'pending')
      company.approve!(admin)
      
      expect(company.reload).to be_approved
      expect(company.approved_by).to eq(admin)
      expect(company.approved_at).to be_present
    end

    it 'rejects company' do
      company = create(:company, status: 'pending')
      company.reject!
      
      expect(company.reload).to be_rejected
    end
  end
end
