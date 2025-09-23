FactoryBot.define do
  factory :job do
    title { Faker::Job.title }
    description { Faker::Lorem.paragraph(sentence_count: 5) }
    employment_type { Job::EMPLOYMENT_TYPES.sample }
    salary_min { rand(50000..80000) }
    salary_max { salary_min + rand(20000..50000) }
    currency { 'USD' }
    status { 'draft' }
    location { Faker::Address.city }
    is_remote { [true, false].sample }
    
    association :company, :approved
    association :posted_by_user, factory: [:user, :recruiter]

    trait :published do
      status { 'published' }
      published_at { Time.current }
      expires_at { 30.days.from_now }
    end

    trait :expired do
      status { 'published' }
      published_at { 2.months.ago }
      expires_at { 1.month.ago }
    end
  end
end
