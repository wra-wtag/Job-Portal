FactoryBot.define do
  factory :job_recommendation do
    user { nil }
    payload { "" }
    algorithm_version { "MyString" }
    generated_at { "2025-09-23 15:21:10" }
    scheduled_for { "2025-09-23 15:21:10" }
    sent_at { "2025-09-23 15:21:10" }
  end
end
