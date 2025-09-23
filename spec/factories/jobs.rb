FactoryBot.define do
  factory :job do
    title { "MyString" }
    company { nil }
    posted_by_user { nil }
    description { "MyText" }
    employment_type { "MyString" }
    salary_min { "9.99" }
    salary_max { "9.99" }
    currency { "MyString" }
    status { "MyString" }
    visibility { false }
    published_at { "2025-09-23 12:23:09" }
    expires_at { "2025-09-23 12:23:09" }
    application_deadline { "2025-09-23 12:23:09" }
    views_count { 1 }
    applications_count { 1 }
  end
end
