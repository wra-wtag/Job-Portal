FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    slug { name.parameterize }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    location { Faker::Address.city }
    website { Faker::Internet.url }
    industry { [ 'Technology', 'Healthcare', 'Finance', 'Education', 'Retail' ].sample }
    size { Company::SIZES.sample }
    status { 'pending' }

    trait :approved do
      status { 'approved' }
      approved_at { Time.current }
      association :approved_by, factory: [ :user, :admin ]
    end

    trait :pending do
      status { 'pending' }
    end

    trait :rejected do
      status { 'rejected' }
    end
  end
end
