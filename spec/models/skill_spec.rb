require "rails_helper"

RSpec.describe Skill, type: :model do
  describe "associations" do
    it { should have_many(:user_skills).dependent(:destroy) }
    it { should have_many(:users).through(:user_skills) }
    it { should have_many(:job_skills).dependent(:destroy) }
    it { should have_many(:jobs).through(:job_skills) }
  end

  describe "validations" do
    subject { build(:skill) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe "scopes" do
    let!(:frontend) { create(:skill, category: "Frontend") }
    let!(:backend)  { create(:skill, category: "Backend") }

    it ".by_category returns skills of a given category" do
      expect(Skill.by_category("Frontend")).to include(frontend)
      expect(Skill.by_category("Frontend")).not_to include(backend)
    end

    it ".popular orders by user_skills count" do
      popular_skill = create(:skill, name: "Ruby")
      user = create(:user)
      create(:user_skill, user: user, skill: popular_skill)

      expect(Skill.popular.first).to eq(popular_skill)
    end
  end

  describe ".find_or_create_by_name" do
    it "finds an existing skill ignoring case and whitespace" do
      skill = create(:skill, name: "Ruby on Rails")
      found = Skill.find_or_create_by_name(" ruby on rails ")
      expect(found.id).to eq(skill.id)
    end

    it "creates a new skill if not found" do
      expect {
        Skill.find_or_create_by_name("GraphQL")
      }.to change { Skill.count }.by(1)
    end

    it "titleizes the name before creating" do
      skill = Skill.find_or_create_by_name("java script")
      expect(skill.name).to eq("Java Script")
    end
  end
end
