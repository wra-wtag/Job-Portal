FactoryBot.define do
  factory :recruiter_membership do
    role { 'standard' }
    title { Faker::Job.title }
    is_primary { false }
    
    association :user, :recruiter
    association :company, :approved

    trait :manager do
      role { 'manager' }
    end

    trait :primary do
      is_primary { true }
    end
  end
end
