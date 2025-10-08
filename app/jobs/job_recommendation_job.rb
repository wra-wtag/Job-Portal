class JobRecommendationJob < ApplicationJob
    queue_as :default

    def perform(user_id)
        user = User.find(user_id)
        return unless user.job_seeker? && user.weekly_recommendations_enabled

        recommended_jobs = generate_recommendations_for_user(user)

        return if recommended_jobs.empty?

        recommendation = user.job_recommendations.create!(
            payload: {
                job_ids: recommended_jobs.pluck(:id),
                algorithm_version: "1.0",
                generated_at: Time.current,
                total_jobs: recommended_jobs.count,
                user_skills: user.skills.pluck(:name),
                user_location: user.location
            },
            algorithm_version: "1.0",
            generated_at: Time.current,
            scheduled_for: Time.current
        )
        JobRecommendationMailer.weekly_recommendations(user, recommended_jobs).deliver_now
        recommendation.mark_as_sent!
    end

    private

    def generate_recommendations_for_user(user)
        jobs = Job.published.active.includes(:company, :skills)
        applied_job_ids = user.applications.pluck(:job_id)
        jobs = jobs.where.not(id: applied_job_ids)
        rejected_company_ids = user.applications.joins(:job)
                                .where(status: "rejected")
                                .includes(job: :company)
                                .map { |app| app.job.company_id }
                                .uniq

        jobs = jobs.where.not(company_id: rejected_company_ids) if rejected_company_ids.any?

        scored_jobs = score_jobs_for_user(jobs, user)
        scored_jobs.first(10)
    end

    def score_jobs_for_user(jobs, user)
        user_skills = user.skills.pluck(:id)
        user_location = user.location&.downcase

        jobs_with_scores = jobs.map do |job|
        score = 0
        job_skill_ids = job.skills.pluck(:id)
        skill_matches = (user_skills & job_skill_ids).count
        total_job_skills = job_skill_ids.count
        if total_job_skills > 0
            skill_score = (skill_matches.to_f / total_job_skills) * 40
            score += skill_score
        end

        if user_location.present? && job.location.present?
            if job.is_remote? || job.location.downcase.include?(user_location)
            score += 20
            end
        end

        days_old = (Time.current - job.published_at) / 1.day
        freshness_score = [ 20 - (days_old * 2), 0 ].max
        score += freshness_score

        case job.company.size
        when "51-200", "201-500"
            score += 10
        when "11-50", "501-1000"
            score += 5
        end

        if job.applications_count < 5
            score += 10
        elsif job.applications_count < 20
            score += 5
        end

        [ job, score ]
        end

        jobs_with_scores.sort_by { |_, score| -score }.map { |job, _| job }
    end
end
