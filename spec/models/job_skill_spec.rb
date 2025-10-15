require 'rails_helper'

RSpec.describe JobSkill, type: :model do
  describe "associations" do
    it { should belong_to(:job) }
    it { should belong_to(:skill) }
  end

  describe "validations" do
    subject { build(:job_skill) }

    it { should validate_uniqueness_of(:job_id).scoped_to(:skill_id) }
  end

  describe "scopes" do
    let!(:required_skill) { create(:job_skill, :required) }
    let!(:optional_skill) { create(:job_skill, :optional) }

    it ".required returns only required job skills" do
      expect(JobSkill.required).to include(required_skill)
      expect(JobSkill.required).not_to include(optional_skill)
    end

    it ".optional returns only optional job skills" do
      expect(JobSkill.optional).to include(optional_skill)
      expect(JobSkill.optional).not_to include(required_skill)
    end
  end
end
