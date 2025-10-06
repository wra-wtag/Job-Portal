module Api
  module V1
    class CompaniesAPI < Grape::API
      resource :companies do
        desc "Return list of companies"
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
          optional :industry, type: String
        end
        get do
          companies = Company.approved

          companies = companies.where(industry: params[:industry]) if params[:industry]
          companies = companies.limit(params[:per_page]).offset((params[:page] - 1) * params[:per_page])

          {
            companies: companies.map do |company|
              {
                id: company.id,
                name: company.name,
                slug: company.slug,
                location: company.location,
                website: company.website,
                industry: company.industry,
                size: company.size,
                active_jobs_count: company.jobs.published.count
              }
            end,
            meta: {
              page: params[:page],
              per_page: params[:per_page],
              total: Company.approved.count
            }
          }
        end

        desc "Return a specific company"
        params do
          requires :id, type: Integer
        end
        route_param :id do
          get do
            company = Company.approved.find(params[:id])

            {
              id: company.id,
              name: company.name,
              slug: company.slug,
              description: company.description,
              location: company.location,
              website: company.website,
              industry: company.industry,
              size: company.size,
              active_jobs: company.jobs.published.map do |job|
                {
                  id: job.id,
                  title: job.title,
                  location: job.location,
                  employment_type: job.employment_type
                }
              end
            }
          end
        end
      end
    end
  end
end
