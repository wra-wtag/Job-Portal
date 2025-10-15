FactoryBot.define do
  factory :job do
    association :company
    association :posted_by_user, factory: :user

    title { Faker::Job.title }
    description { Faker::Lorem.paragraph(sentence_count: 5) }
    employment_type { Job.employment_types.keys.sample }
    status { :draft }
    salary_min { Faker::Number.between(from: 30_000, to: 50_000) }
    salary_max { Faker::Number.between(from: 60_000, to: 100_000) }
    currency { "USD" }
    expires_at { Faker::Date.forward(days: 60) }
    views_count { 0 }

    trait :published do
      status { :published }
      published_at { Time.current }
    end

    trait :closed do
      status { :closed }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end
  end
end
