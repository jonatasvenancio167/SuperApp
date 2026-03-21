FactoryBot.define do
  factory :school do
    name { Faker::Educator.university }
    code { Faker::Number.unique.number(digits: 5).to_s }
  end
end
