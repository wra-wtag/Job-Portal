require "rails_helper"

RSpec.describe RecruiterMembership, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:company) }
  end

  describe "validations" do
    subject { build(:recruiter_membership) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:company_id) }
  end

  describe "scopes" do
    let!(:manager_membership) { create(:recruiter_membership, :manager) }
    let!(:standard_membership) { create(:recruiter_membership, :standard) }
    let!(:primary_membership) { create(:recruiter_membership, :primary) }

    it ".managers returns only manager roles" do
      expect(RecruiterMembership.managers).to include(manager_membership)
      expect(RecruiterMembership.managers).not_to include(standard_membership)
    end

    it ".standard returns only standard roles" do
      expect(RecruiterMembership.standard).to include(standard_membership)
      expect(RecruiterMembership.standard).not_to include(manager_membership)
    end

    it ".primary returns only primary memberships" do
      expect(RecruiterMembership.primary).to include(primary_membership)
    end
  end

  describe "instance methods" do
    let(:manager) { create(:recruiter_membership, :manager, :approved) }
    let(:standard) { create(:recruiter_membership, :standard, :approved) }
    let(:pending_manager) { create(:recruiter_membership, :manager, :pending) }

    it "#manager? returns true for manager role" do
      expect(manager.manager?).to be true
      expect(standard.manager?).to be false
    end

    it "#standard? returns true for standard role" do
      expect(standard.standard?).to be true
      expect(manager.standard?).to be false
    end

    it "#can_manage_recruiters? returns true only for approved managers" do
      expect(manager.can_manage_recruiters?).to be true
      expect(standard.can_manage_recruiters?).to be false
      expect(pending_manager.can_manage_recruiters?).to be false
    end
  end
end
