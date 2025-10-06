class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :confirmable

  enum :role, { job_seeker: 0, recruiter: 1, admin: 2 }

  validates :first_name, :last_name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, email: true

  has_many :applications, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :user_skills, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_jobs, through: :bookmarks, source: :job
  has_many :skills, through: :user_skills
  has_many :job_recommendations, dependent: :destroy

  has_many :recruiter_memberships, dependent: :destroy
  has_many :companies, through: :recruiter_memberships
  has_many :posted_jobs, class_name: "Job", foreign_key: "posted_by_user_id", dependent: :destroy

  has_many :approved_companies, class_name: "Company", foreign_key: "approved_by_id"

  has_one_attached :resume

  def full_name
    "#{first_name} #{last_name}"
  end

  def primary_company
    recruiter_memberships.where(is_primary: true).first&.company
  end

  def can_post_jobs?
    recruiter? && recruiter_memberships.approved.joins(:company).where(companies: { status: "approved" }).any?
  end

  def primary_company
    recruiter_memberships.approved.where(is_primary: true).first&.company
  end

  def managed_companies
    recruiter_memberships.approved.managers.includes(:company).map(&:company)
  end

  def standard_companies
    recruiter_memberships.approved.standard.includes(:company).map(&:company)
  end

  def can_manage_company?(company)
    recruiter_memberships.approved.managers.exists?(company: company)
  end

  def has_any_recruiter_requests?
    recruiter_memberships.pending.any? || companies.pending.any?
  end

  def needs_onboarding?
    recruiter? && !has_company_request?
  end

  before_create :generate_authentication_token

  def regenerate_authentication_token
    generate_authentication_token
    save
  end

  private

  def assign_skills_from_list
    return unless skills_list.present?

    skill_names = Array(skills_list).map(&:strip).reject(&:blank?)

    new_skills = skill_names.map do |name|
      Skill.where("LOWER(name) = ?", name.downcase).first_or_create(name: name)
    end

    self.skills = new_skills
  end

  def generate_username
    self.username = "#{first_name.downcase}#{last_name.downcase}#{rand(1000)}" if username.blank?
  end

  def generate_authentication_token
    loop do
      self.authentication_token = SecureRandom.hex(20)
      break unless User.exists?(authentication_token: authentication_token)
    end
  end
end
