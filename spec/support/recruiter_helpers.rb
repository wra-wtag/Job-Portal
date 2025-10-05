module RecruiterHelpers
  def create_recruiter_with_company
    admin = create(:user, :admin)
    company = create(:company, :approved, approved_by: admin)
    recruiter = create(:user, :recruiter)

    create(:recruiter_membership,
      user: recruiter,
      company: company,
      role: 'manager',
      is_primary: true
    )

    { recruiter: recruiter, company: company }
  end
end

RSpec.configure do |config|
  config.include RecruiterHelpers, type: :request
end
