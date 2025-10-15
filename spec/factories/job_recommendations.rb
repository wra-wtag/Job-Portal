FactoryBot.define do
  factory :job_recommendation do
    association :user
    algorithm_version { "v1" }
    generated_at      { Time.current }
    payload { { "job_ids" => [] } }

    trait :sent do
      sent_at { Time.current }
    end

    trait :pending do
      sent_at { nil }
    end
  end
end
