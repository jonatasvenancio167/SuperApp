FactoryBot.define do
  factory :guardian do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
  end
end
