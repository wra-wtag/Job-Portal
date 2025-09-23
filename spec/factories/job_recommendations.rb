FactoryBot.define do
  factory :job_recommendation do
    user { nil }
    payload { "" }
    algorithm_version { "MyString" }
    generated_at { "2025-09-22 18:49:34" }
    scheduled_for { "2025-09-22 18:49:34" }
    sent_at { "2025-09-22 18:49:34" }
  end
end
