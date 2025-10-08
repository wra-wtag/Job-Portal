class RecruiterMailer < ApplicationMailer
  def request_approved(membership)
    @membership = membership
    @user = membership.user
    @company = membership.company

    mail(
      to: @user.email,
      subject: "Your recruiter request for #{@company.name} has been approved!"
    )
  end
end
