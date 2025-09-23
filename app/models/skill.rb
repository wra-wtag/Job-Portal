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
        find_or_create_by(name: name.strip.titleize)
    end
end
