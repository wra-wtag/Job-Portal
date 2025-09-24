FactoryBot.define do
  factory :job_recommendation do
    association :user

    payload { { 'job_ids' => [] } }
    algorithm_version { "v1.0" }
    generated_at { Time.current }
    scheduled_for { Date.current }
    sent_at { nil }

    trait :sent do
      sent_at { Time.current }
    end

    trait :pending do
      sent_at { nil }
    end
  end
end
