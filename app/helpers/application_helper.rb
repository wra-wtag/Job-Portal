module ApplicationHelper
    def recruiter_onboarding_page?
        controller_name == "recruiter_onboarding" ||
        (controller_name == "companies" && action_name == "pending_approval")
    end
end
