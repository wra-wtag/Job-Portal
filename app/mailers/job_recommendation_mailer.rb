class JobRecommendationMailer < ApplicationMailer
    default from: "noreply@jobportal.com"

    def weekly_recommendations(user, jobs)
        @user = user
        @jobs = jobs

        mail(
            to: user.email,
            subject: "#{jobs.count} new job recommendations for you"
        )
    end
end
