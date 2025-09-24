FactoryBot.define do
  factory :application do
    cover_letter { Faker::Lorem.paragraph(sentence_count: 3) }
    status { 'applied' }
    applied_at { Time.current }
    
    association :job, :published
    association :user, :job_seeker

    trait :viewed do
      status { 'viewed' }
    end

    trait :shortlisted do
      status { 'shortlisted' }
    end

    trait :rejected do
      status { 'rejected' }
    end
  end
end
