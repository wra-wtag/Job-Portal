FactoryBot.define do
  factory :recruiter_membership do
    association :user
    association :company
    role { RecruiterMembership::ROLES.sample }
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
  end
end
