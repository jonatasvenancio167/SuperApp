require 'rails_helper'

RSpec.describe School, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      school = build(:school)
      expect(school).to be_valid
    end

    it "is invalid without a name" do
      school = build(:school, name: nil)
      expect(school).not_to be_valid
      expect(school.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a code" do
      school = build(:school, code: nil)
      expect(school).not_to be_valid
      expect(school.errors[:code]).to include("can't be blank")
    end

    it "is invalid with a duplicate code" do
      create(:school, code: "12345")
      school = build(:school, code: "12345")
      expect(school).not_to be_valid
      expect(school.errors[:code]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many classrooms" do
      school = create(:school)
      classroom1 = create(:classroom, school: school)
      classroom2 = create(:classroom, school: school)
      expect(school.classrooms).to include(classroom1, classroom2)
    end

    it "has many announcements" do
      school = create(:school)
      announcement1 = create(:announcement, school: school)
      announcement2 = create(:announcement, school: school)
      expect(school.announcements).to include(announcement1, announcement2)
    end

    it "has many students through classrooms" do
      school = create(:school)
      classroom = create(:classroom, school: school)
      student = create(:student)
      create(:student_classroom, student: student, classroom: classroom)
      expect(school.students).to include(student)
    end

    it "destroys dependent classrooms when school is destroyed" do
      school = create(:school)
      create(:classroom, school: school)
      expect { school.destroy }.to change(Classroom, :count).by(-1)
    end

    it "destroys dependent announcements when school is destroyed" do
      school = create(:school)
      create(:announcement, school: school)
      expect { school.destroy }.to change(Announcement, :count).by(-1)
    end
  end
end
