class UserSerializer < ActiveModel::Serializer
    attributes :id, :email, :first_name, :last_name, :username, :full_name, :role, :bio, :location, :created_at

    attribute :companies, if: :recruiter? do
        object.companies.approved.map do |company|
            {
                id: company.id,
                name: company.name,
                status: company.status
            }
        end
    end

    def full_name
        object.full_name
    end

    def recruiter?
        object.recruiter?
    end
end
