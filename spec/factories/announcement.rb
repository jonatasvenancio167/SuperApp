FactoryBot.define do
  factory :announcement do
    school
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    scope { "school" }
    status { "draft" }

    trait :sent do
      status { "sent" }
      sent_at { Time.current }
    end

    trait :with_classrooms do
      scope { "classrooms" }
      after(:create) do |announcement|
        classroom = create(:classroom, school: announcement.school)
        create(:announcement_classroom, announcement: announcement, classroom: classroom)
      end
    end

    trait :with_students do
      scope { "students" }
      after(:create) do |announcement|
        student = create(:student)
        create(:announcement_student, announcement: announcement, student: student)
      end
    end
  end

  factory :announcement_classroom do
    announcement
    classroom
  end

  factory :announcement_student do
    announcement
    student
  end
end
