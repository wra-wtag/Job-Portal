module Api
    module V1
        class CompaniesController < BaseController
            skip_before_action :authenticate_api_user!, only: [ :index, :show ]

            # GET /api/v1/companies
            def index
                companies = Company.approved.includes(:jobs)

                if params[:search].present?
                    search_term = params[:search].strip
                    companies = companies.where(
                        "name ILIKE ? OR industry ILIKE ?",
                        "%#{search_term}%", "%#{search_term}"
                    )
                end

                if params[:industry].present?
                    companies = companies.where(industry: params[:industry])
                end

                if params[:location].present?
                    companies = companies.where("location ILIKE?", "%#{params[:location]}%")
                end

                page = params[:page] || 1
                per_page = params[:per_page] || 20

                paginated_companies = companies.page(page).per(per_page)

                render_success(
                    ActiveModel::Serializer::CollectionSerializer.new(
                        paginated_companies,
                        serializer: CompanySerializer
                    ),
                    :ok,
                    {
                        current_page: paginated_companies.current_page,
                        total_pages: paginated_companies.total_pages,
                        total_count: paginated_companies.total_count,
                        per_page: per_page.to_i
                    }
                )
            end

            # GET /api/v1/companies/:id
            def show
                company = Company.approved.find(params[:id])

                jobs = company.jobs.published.active.includes(:skills)

                render_success(
                    company: CompanySerializer.new(company),
                    jobs: ActiveModel::Serializer::CollectionSerializer.new(
                        jobs,
                        serializer: JobSerializer
                    )
                )
            end
        end
    end
end
