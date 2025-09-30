FactoryBot.define do
  factory :job_skill do
    association :job
    association :skill
    required { [ true, false ].sample }

    trait :required do
      required { true }
    end

    trait :optional do
      required { false }
    end
  end
end
