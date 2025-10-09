class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :description, :location,
             :website, :industry, :size, :status,
             :created_at

  attribute :logo_url do
    object.logo.attached? ? Rails.application.routes.url_helpers.rails_blob_url(object.logo, only_path: true) : nil
  end

  attribute :jobs_count do
    object.jobs.published.count
  end
end
