FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.unique.username }
    role { :job_seeker }
    email_verified { true }
    confirmed_at { Time.current }

    trait :job_seeker do
      role { :job_seeker }
      bio { Faker::Lorem.paragraph }
      location { Faker::Address.city }
    end

    trait :recruiter do
      role { :recruiter }
    end

    trait :admin do
      role { :admin }
    end
  end
end
