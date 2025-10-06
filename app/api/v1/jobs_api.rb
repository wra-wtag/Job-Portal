module Api
  module V1
    class JobsAPI < Grape::API
      resource :jobs do
        desc "Return list of jobs"
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
          optional :search, type: String
          optional :location, type: String
          optional :employment_type, type: String
        end
        get do
          jobs = Job.published.includes(:company, :skills)

          if params[:search]
            jobs = jobs.where("title ILIKE ? OR description ILIKE ?",
                            "%#{params[:search]}%", "%#{params[:search]}%")
          end

          jobs = jobs.where("location ILIKE ?", "%#{params[:location]}%") if params[:location]
          jobs = jobs.where(employment_type: params[:employment_type]) if params[:employment_type]

          jobs = jobs.limit(params[:per_page]).offset((params[:page] - 1) * params[:per_page])

          {
            jobs: jobs.map do |job|
              {
                id: job.id,
                title: job.title,
                description: job.description,
                location: job.location,
                employment_type: job.employment_type,
                is_remote: job.is_remote,
                salary_min: job.salary_min,
                salary_max: job.salary_max,
                currency: job.currency,
                published_at: job.published_at,
                company: {
                  id: job.company.id,
                  name: job.company.name,
                  location: job.company.location,
                  industry: job.company.industry
                },
                skills: job.skills.map { |s| { id: s.id, name: s.name } }
              }
            end,
            meta: {
              page: params[:page],
              per_page: params[:per_page],
              total: Job.published.count
            }
          }
        end

        desc "Return a specific job"
        params do
          requires :id, type: Integer
        end
        route_param :id do
          get do
            job = Job.published.find(params[:id])
            job.increment_views!

            {
              id: job.id,
              title: job.title,
              description: job.description,
              location: job.location,
              employment_type: job.employment_type,
              is_remote: job.is_remote,
              salary_min: job.salary_min,
              salary_max: job.salary_max,
              currency: job.currency,
              published_at: job.published_at,
              expires_at: job.expires_at,
              views_count: job.views_count,
              applications_count: job.applications_count,
              company: {
                id: job.company.id,
                name: job.company.name,
                slug: job.company.slug,
                description: job.company.description,
                location: job.company.location,
                website: job.company.website,
                industry: job.company.industry,
                size: job.company.size
              },
              skills: job.skills.map { |s| { id: s.id, name: s.name, category: s.category } }
            }
          end
        end
      end
    end
  end
end
