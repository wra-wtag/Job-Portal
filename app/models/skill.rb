class Skill < ApplicationRecord
    # validations
    validates :name, presence: true, uniqueness: { case_sensitive: false }

    # associations
    has_many :user_skills, dependent: :destroy
    has_many :users, through: :user_skills
    has_many :job_skills, dependent: :destroy
    has_many :jobs, through: :job_skills

    # Scopes
    scope :by_category, ->(category) { where(category: category) }
    scope :popular, -> { joins(:user_skills).group(:id).order('COUNT(user_skills.id) DESC') }

    # Methods
    def self.find_or_create_by_name(name)
        normalized_name = name.strip.titleize
        skill = Skill.where("LOWER(name) = ?", normalized_name.downcase).first
        skill || Skill.create!(name: normalized_name)
    end
end
