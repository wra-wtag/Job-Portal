module Api
  module V1
    class ApplicationsAPI < Grape::API
      before do
        authenticate!
      end

      resource :applications do
        desc "Return user applications"
        get do
          applications = current_user.applications.includes(:job)

          {
            applications: applications.map do |app|
              {
                id: app.id,
                status: app.status,
                applied_at: app.applied_at,
                job: {
                  id: app.job.id,
                  title: app.job.title,
                  company_name: app.job.company.name,
                  location: app.job.location
                }
              }
            end,
            meta: {
              total: applications.count
            }
          }
        end

        desc "Create a new application"
        params do
          requires :job_id, type: Integer
          requires :cover_letter, type: String
        end
        post do
          job = Job.find(params[:job_id])

          if current_user.applications.exists?(job: job)
            error!("You have already applied for this job", 422)
          end

          application = current_user.applications.create!(
            job: job,
            cover_letter: params[:cover_letter],
            applied_at: Time.current
          )

          {
            id: application.id,
            status: application.status,
            applied_at: application.applied_at,
            job: {
              id: job.id,
              title: job.title
            }
          }
        end

        desc "Get application details"
        params do
          requires :id, type: Integer
        end
        route_param :id do
          get do
            application = current_user.applications.find(params[:id])

            {
              id: application.id,
              status: application.status,
              applied_at: application.applied_at,
              cover_letter: application.cover_letter,
              job: {
                id: application.job.id,
                title: application.job.title,
                description: application.job.description,
                company_name: application.job.company.name,
                location: application.job.location
              }
            }
          end
        end
      end
    end
  end
end
