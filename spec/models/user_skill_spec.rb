require "rails_helper"

RSpec.describe UserSkill, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:skill) }
  end

  describe "validations" do
    subject { build(:user_skill) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:skill_id) }
    it { should validate_numericality_of(:experience_years).is_greater_than_or_equal_to(0) }
  end

  describe "scopes" do
    let!(:junior_skill) { create(:user_skill, experience_years: 1) }
    let!(:senior_skill) { create(:user_skill, experience_years: 5) }

    it ".by_experience returns skills with experience >= given years" do
      expect(UserSkill.by_experience(3)).to include(senior_skill)
      expect(UserSkill.by_experience(3)).not_to include(junior_skill)
    end
  end
end
