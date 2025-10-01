FactoryBot.define do
  factory :notification do
    association :user

    title { Faker::Lorem.sentence(word_count: 5) }
    kind { Notification.kinds.keys.sample }
    read_at { nil }

    trait :read do
      read_at { Time.current }
    end

    trait :unread do
      read_at { nil }
    end
  end
end
