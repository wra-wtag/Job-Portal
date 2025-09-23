FactoryBot.define do
  factory :company do
    name { Faker::Company.unique.name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    location { Faker::Address.city }
    website { Faker::Internet.url }
    industry { ['Technology', 'Healthcare', 'Finance', 'Education', 'Retail'].sample }
    size { Company::SIZES.sample }
    status { 'pending' }

    after(:build) do |company|
      company.slug = company.name.parameterize if company.name.present?
    end

    trait :approved do
      status { 'approved' }
      approved_at { Time.current }
      association :approved_by, factory: [:user, :admin]
    end

    trait :rejected do
      status { 'rejected' }
    end
  end
end
