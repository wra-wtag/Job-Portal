FactoryBot.define do
  factory :application do
    association :job
    association :user

    cover_letter { Faker::Lorem.paragraph(sentence_count: 3) }
    status { Application.statuses[:applied] }
    applied_at { Time.current }

    trait :applied do
      status { Application.statuses[:applied] }
    end

    trait :viewed do
      status { Application.statuses[:viewed] }
    end

    trait :shortlisted do
      status { Application.statuses[:shortlisted] }
    end

    trait :rejected do
      status { Application.statuses[:rejected] }
    end

    trait :hired do
      status { Application.statuses[:hired] }
    end

    trait :withdrawn do
      status { Application.statuses[:withdrawn] }
    end
  end
end
