require 'rails_helper'

RSpec.describe Student, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      student = build(:student)
      expect(student).to be_valid
    end

    it "is invalid without a name" do
      student = build(:student, name: nil)
      expect(student).not_to be_valid
      expect(student.errors[:name]).to include("can't be blank")
    end
  end

  describe "associations" do
    let(:student) { create(:student) }

    it "has many classrooms through student_classrooms" do
      classroom1 = create(:classroom)
      classroom2 = create(:classroom)
      create(:student_classroom, student: student, classroom: classroom1)
      create(:student_classroom, student: student, classroom: classroom2)
      expect(student.classrooms).to include(classroom1, classroom2)
    end

    it "has many guardians through student_guardians" do
      guardian1 = create(:guardian)
      guardian2 = create(:guardian)
      create(:student_guardian, student: student, guardian: guardian1)
      create(:student_guardian, student: student, guardian: guardian2)
      expect(student.guardians).to include(guardian1, guardian2)
    end
  end
end
