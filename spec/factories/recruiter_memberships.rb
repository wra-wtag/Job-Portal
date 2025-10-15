FactoryBot.define do
  factory :recruiter_membership do
    association :user
    association :company

    role { RecruiterMembership.roles.keys.sample }
    status { RecruiterMembership.statuses.keys.sample }
    is_primary { false }

    trait :manager do
      role { 'manager' }
    end

    trait :standard do
      role { 'standard' }
    end

    trait :primary do
      is_primary { true }
    end

    trait :pending do
      status { 'pending' }
    end

    trait :approved do
      status { 'approved' }
    end

    trait :rejected do
      status { 'rejected' }
    end
  end
end
