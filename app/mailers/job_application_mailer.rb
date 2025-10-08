class JobApplicationMailer < ApplicationMailer
  default from: "noreply@jobportal.com"

  def new_application(application)
    @application = application
    @job = application.job
    @company = @job.company
    @applicant = application.user

    @company.recruiters.each do |recruiter|
      mail(
        to: recruiter.email,
        subject: "New Application: #{@applicant.full_name} applied for #{@job.title}"
      )
    end
  end

  def application_status_update(application)
    @application = application
    @job = application.job
    @company = @job.company
    @applicant = application.user

    mail(
      to: @applicant.email,
      subject: "Application Update: #{@job.title} at #{@company.name}"
    )
  end
end
