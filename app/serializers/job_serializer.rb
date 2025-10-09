class JobSerializer < ActiveModel::Serializer
    attributes :id, :title, :description, :employment_type, :location, :is_remote, :salary_min, :salary_max, :currency, :status, :views_count, :applications_count, :published_at, :expires_at, :application_deadline, :created_at, :updated_at

    belongs_to :company, serializer: CompanySerializer
    has_many :skills, serializer: SkillSerializer

    attribute :salary_range do
        object.salary_range
    end

    attribute :is_active do
        object.active?
    end

    attribute :posted_by do
        {
            id: object.posted_by_user.id,
            name: object.posted_by_user.full_name
        }
    end
end
