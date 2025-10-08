class CompanyApprovalMailer < ApplicationMailer
    default from: "noreply@jobportal.com"

    def approved(company)
        @company = company
        @recruiters = company.recruiters

        @recruiters.each do |recruiter|
        mail(
            to: recruiter.email,
            subject: "🎉 Your company #{@company.name} has been approved!"
        )
        end
    end

    def rejected(company)
        @company = company
        @recruiters = company.recruiters

        @recruiters.each do |recruiter|
        mail(
            to: recruiter.email,
            subject: "Company application update for #{@company.name}"
        )
        end
    end
end
