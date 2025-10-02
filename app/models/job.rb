class Job < ApplicationRecord
  belongs_to :company
  belongs_to :posted_by_user, class_name: "User"
  enum :employment_type, { full_time: 0, part_time: 1, contract: 2, internship: 3, temporary: 4 }
  enum :status, { draft: 0, published: 1, closed: 2 }

  validates :title, :description, presence: true
  validates :salary_min, :salary_max, numericality: { greater_than: 0 }, allow_blank: true
  validate :salary_max_greater_than_min

  has_many :applications, dependent: :destroy
  has_many :applicants, through: :applications, source: :user
  has_many :bookmarks, dependent: :destroy
  has_many :job_skills, dependent: :destroy
  has_many :skills, through: :job_skills

  scope :published, -> { where(status: :published) }
  scope :active, -> { published.where("expires_at > ? OR expires_at IS NULL", Time.current) }
  scope :by_employment_type, ->(type) { where(employment_type: type) }
  scope :with_salary_range, ->(min, max) { where(salary_min: min..max) }
  scope :recent, -> { order(created_at: :desc) }

  before_save :set_published_at, if: :status_changed_to_published?

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def active?
    published? && !expired?
  end

  def increment_views!
    increment!(:views_count)
  end

  def employment_type_humanized
    employment_type.humanize
  end

  def salary_range
    return nil unless salary_min.present? && salary_max.present?

    "#{currency} #{salary_min.to_i} - #{salary_max.to_i}"
  end

  private

  def salary_max_greater_than_min
    return unless salary_min.present? && salary_max.present?

    errors.add(:salary_max, "must be greater than minimum salary") if salary_max < salary_min
  end

  def status_changed_to_published?
    will_save_change_to_status? && published?
  end

  def set_published_at
    self.published_at = Time.current
  end
end
