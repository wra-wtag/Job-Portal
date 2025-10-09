class ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :status, :cover_letter, :applied_at,
             :created_at, :updated_at

  belongs_to :job, serializer: JobSerializer
  belongs_to :user, serializer: UserSerializer

  attribute :can_withdraw do
    object.can_withdraw?
  end

  attribute :resume_url do
    if object.resume.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.resume, only_path: true)
    end
  end
end
