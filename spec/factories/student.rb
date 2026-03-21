FactoryBot.define do
  factory :student do
    name { Faker::Name.name }
    
    trait :with_classroom do
      after(:create) do |student|
        create(:student_classroom, student: student)
      end
    end
  end

  factory :student_classroom do
    student
    classroom
  end

  factory :student_guardian do
    student
    guardian
  end
end
