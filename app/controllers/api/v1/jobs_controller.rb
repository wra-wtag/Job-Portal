module Api
    module V1
        class JobsController < BaseController
            skip_before_action :authenticate_api_user!, only: [ :index, :show ]

            # GET /api/v1/jobs
            def index
                jobs = Job.published.active.includes(:company, :skills)

                jobs = apply_filters(jobs)

                jobs = apply_search(jobs) if params[:search].present?

                jobs = apply_sorting(jobs)

                page = params[:page] || 1
                per_page = params[:per_page] || 20

                paginated_jobs = jobs.page(page).per(per_page)

                render_success(
                    ActiveModel::Serializer::CollectionSerializer.new(
                        paginated_jobs,
                        serializer: JobSerializer
                    ),
                    :ok,
                    {
                        current_page: paginated_jobs.current_page,
                        total_pages: paginated_jobs.total_pages,
                        total_count: paginated_jobs.total_count,
                        per_page: per_page.to_i
                    }
                )
            end

            # GET /api/v1/jobs/:id
            def show
                job = Job.published.find(params[:id])
                job.increment_views!

                render_success(JobSerializer.new(job))
            end

            # POST /api/v1/jobs/:id/apply
            def apply
                job = Job.published.active.find(params[:id])

                unless current_user.job_seeker?
                    return render_error("Only job seekers can apply for jobs", :forbidden)
                end

                if current_user.applications.exists?(job: job)
                    return render_error("You have already applied for this job", :unprocessable_content)
                end

                application = current_user.applications.build(
                    job: job,
                    cover_letter: params[:cover_letter],
                    applied_at: Time.current
                )

                # Handle resume upload if provided
                if params[:resume].present?
                    application.resume.attach(params[:resume])
                end

                if application.save
                    # Send notification to recruiters
                    job.company.recruiters.each do |recruiter|
                        Notification.create!(
                            user: recruiter,
                            kind: "new_job_application",
                            title: "New Job Application",
                            content: "#{current_user.full_name} applied for #{job.title}"
                        )
                    end

                    # Send email (in background)
                    JobApplicationMailer.new_application(application).deliver_later

                    render_success(
                        ApplicationSerializer.new(application),
                        :created
                    )
                else
                    render json: { errors: application.errors.full_messages }, status: :unprocessable_content
                end
            end

            private

            def apply_filters(jobs)
                jobs = jobs.where(employment_type: params[:employment_type]) if params[:employment_type].present?
                jobs = jobs.where(is_remote: true) if params[:remote] == "true"
                jobs = jobs.joins(:company).where(companies: { industry: params[:industry] }) if params[:industry].present?
                jobs = jobs.where("jobs.location ILIKE ?", "%#{params[:location]}%") if params[:location].present?

                if params[:salary_min].present?
                    jobs = jobs.where("salary_min >= ?", params[:salary_min])
                end

                if params[:salary_max].present?
                    jobs = jobs.where("salary_max <= ?", params[:salary_max])
                end

                jobs
            end

            def apply_search(jobs)
                search_term = params[:search].strip
                jobs.where(
                    "jobs.title ILIKE ? OR jobs.description ILIKE ? OR companies.name ILIKE ?",
                    "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"
                    ).joins(:company)
            end

            def apply_sorting(jobs)
                case params[:sort]
                when "newest"
                    jobs.order(published_at: :desc)
                when "oldest"
                    jobs.order(published_at: :asc)
                when "salary_high"
                    jobs.order(salary_max: :desc, salary_min: :desc)
                when "salary_low"
                    jobs.order(salary_min: :asc, salary_max: :asc)
                when "company"
                    jobs.joins(:company).order("companies.name ASC")
                else
                    jobs.order(published_at: :desc)
                end
            end
        end
    end
end
