FactoryBot.define do
  factory :application do
    association :job
    association :user

    cover_letter { Faker::Lorem.paragraph(sentence_count: 3) }
    status { Application::STATUSES.sample }
    applied_at { Time.current }

    trait :applied do
      status { "applied" }
    end

    trait :viewed do
      status { "viewed" }
    end

    trait :shortlisted do
      status { "shortlisted" }
    end

    trait :rejected do
      status { "rejected" }
    end

    trait :hired do
      status { "hired" }
    end

    trait :withdrawn do
      status { "withdrawn" }
    end
  end
end
