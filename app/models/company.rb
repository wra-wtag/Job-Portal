class Company < ApplicationRecord
  belongs_to :approved_by, class_name: "User", optional: true
  STATUSES = %w[pending approved rejected].freeze
  SIZES = ['1-10', '11-50', '51-200', '201-500', '501-1000', '1000+'].freeze

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :size, inclusion: { in: SIZES }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  # Associations
  belongs_to :approved_by, class_name: 'User', optional: true
  has_many :recruiter_memberships, dependent: :destroy
  has_many :recruiters, through: :recruiter_memberships, source: :user
  has_many :jobs, dependent: :destroy

  # ActiveStorage
  has_one_attached :logo

  # Scopes
  scope :approved, -> { where(status: 'approved') }
  scope :pending, -> { where(status: 'pending') }
  scope :rejected, -> { where(status: 'rejected') }

  # Callbacks
  before_validation :generate_slug, if: :name_changed?

  # Methods
  def approved?
    status == 'approved'
  end

  def pending?
    status == 'pending'
  end

  def rejected?
    status == 'rejected'
  end

  def approve!(admin_user)
    update!(status: 'approved', approved_by: admin_user, approved_at: Time.current)
  end

  def reject!
    update!(status: 'rejected')
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
