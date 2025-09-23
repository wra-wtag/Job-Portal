FactoryBot.define do
  factory :recruiter_membership do
    user { nil }
    company { nil }
    role { "MyString" }
    title { "MyString" }
    is_primary { false }
    contact_info { "" }
  end
end
