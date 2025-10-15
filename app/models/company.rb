class Company < ApplicationRecord
  belongs_to :approved_by, class_name: "User", optional: true
  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending
  SIZES = [ "1-10", "11-50", "51-200", "201-500", "501-1000", "1000+" ].freeze

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :size, inclusion: { in: SIZES }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :status, presence: true

  has_many :recruiter_memberships, dependent: :destroy
  has_many :recruiters, through: :recruiter_memberships, source: :user
  has_many :jobs, dependent: :destroy

  has_one_attached :logo

  validates :logo, content_type: [ "image/png", "image/jpeg", "image/jpg" ], size: { less_than: 2.megabytes, message: "must be a PNG or JPG image smaller than 3 MB" }, allow_blank: true

  before_validation :generate_slug, if: :name_changed?

  def approve!(admin_user)
    raise StandardError, "Unauthorized: Only admin users can approve companies" unless admin_user&.admin?
    raise StandardError, "Company cannot be approved!" unless can_approve?

    update!(status: :approved, approved_by: admin_user, approved_at: Time.current)
  end

  def reject!
    raise StandardError, "Unauthorized: Only admin users can reject companies" unless admin_user&.admin?
    raise StandardError, "Company cannot be rejected!" unless can_reject?

    update!(status: :rejected)
  end

  def can_approve?
    pending?
  end

  def can_reject?
    pending?
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
