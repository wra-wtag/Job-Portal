module Api
    module V1
        class ApplicationsController < BaseController
            before_action :ensure_job_seeker!, only: [ :index, :show ]

            # GET /api/v1/applications
            def index
                applications = current_user.applications
                                           .includes(:job, job: :company)
                                           .order(applied_at: :desc)

                if params[:status].present?
                    applications = applications.where(status: params[:status])
                end

                page = params[:page] || 1
                per_page = params[:per_page] || 20

                paginated_applications = applications.page(page).per(per_page)

                render_success(
                    ActiveModel::Serializer::CollectionSerializer.new(
                        paginated_applications,
                        serializer: ApplicationSerializer
                    ),
                    :ok,
                    {
                        current_page: paginated_applications.current_page,
                        total_pages: paginated_applications.total_pages,
                        total_count: paginated_applications.total_count,
                        per_page: per_page.to_i
                    }
                )
            end

            # GET /api/v1/applications/:id
            def show
                application = current_user.applications.find(params[:id])
                render_success(ApplicationSerializer.new(application))
            end

            private

            def ensure_job_seeker!
                unless current_user.job_seeker?
                    render_error("Access denied. Only job seekers can access applications.", :forbidden)
                end
            end
        end
    end
end
