# spec/models/company_spec.rb
require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_inclusion_of(:status).in_array(Company::STATUSES) }
  end

  describe 'associations' do
    it { should have_many(:recruiter_memberships).dependent(:destroy) }
    it { should have_many(:jobs).dependent(:destroy) }
    it { should belong_to(:approved_by).optional }
  end

  describe 'callbacks' do
    it 'generates slug from name' do
      company = create(:company, name: 'Test Company Inc')
      expect(company.slug).to eq('test-company-inc')
    end
  end
end