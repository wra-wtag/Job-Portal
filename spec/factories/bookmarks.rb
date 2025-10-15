FactoryBot.define do
  factory :bookmark do
    association :user
    association :job
  end
end
