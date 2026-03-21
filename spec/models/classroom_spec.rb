require 'rails_helper'

RSpec.describe Classroom, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      classroom = build(:classroom)
      expect(classroom).to be_valid
    end

    it "is invalid without a name" do
      classroom = build(:classroom, name: nil)
      expect(classroom).not_to be_valid
      expect(classroom.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a grade" do
      classroom = build(:classroom, grade: nil)
      expect(classroom).not_to be_valid
      expect(classroom.errors[:grade]).to include("can't be blank")
    end

    it "is invalid without a school" do
      classroom = build(:classroom, school: nil)
      expect(classroom).not_to be_valid
    end
  end

  describe "associations" do
    let(:school) { create(:school) }
    let(:classroom) { create(:classroom, school: school) }

    it "belongs to a school" do
      expect(classroom.school).to eq(school)
    end

    it "has many students through student_classrooms" do
      student1 = create(:student)
      student2 = create(:student)
      create(:student_classroom, student: student1, classroom: classroom)
      create(:student_classroom, student: student2, classroom: classroom)
      expect(classroom.students).to include(student1, student2)
    end

    it "has many announcements through announcement_classrooms" do
      announcement = create(:announcement, school: school, scope: "classrooms")
      create(:announcement_classroom, announcement: announcement, classroom: classroom)
      expect(classroom.announcements).to include(announcement)
    end

    it "destroys dependent student_classrooms when classroom is destroyed" do
      student = create(:student)
      create(:student_classroom, student: student, classroom: classroom)
      expect { classroom.destroy }.to change(StudentClassroom, :count).by(-1)
    end
  end
end
