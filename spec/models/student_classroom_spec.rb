# spec/models/student_classroom_spec.rb
require "rails_helper"

RSpec.describe StudentClassroom, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:student) }
    it { is_expected.to belong_to(:classroom) }
  end

  describe "validations" do
    it "is valid with student and classroom" do
      student   = create(:student)
      classroom = create(:classroom)
      record    = StudentClassroom.new(student: student, classroom: classroom)

      expect(record).to be_valid
    end

    it "does not allow the same student in the same classroom twice" do
      student   = create(:student)
      classroom = create(:classroom)

      StudentClassroom.create!(student: student, classroom: classroom)

      expect {
        StudentClassroom.create!(student: student, classroom: classroom)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows the same student in different classrooms" do
      student    = create(:student)
      classroom1 = create(:classroom)
      classroom2 = create(:classroom)

      StudentClassroom.create!(student: student, classroom: classroom1)
      record = StudentClassroom.new(student: student, classroom: classroom2)

      expect(record).to be_valid
    end

    it "allows different students in the same classroom" do
      student1  = create(:student)
      student2  = create(:student)
      classroom = create(:classroom)

      StudentClassroom.create!(student: student1, classroom: classroom)
      record = StudentClassroom.new(student: student2, classroom: classroom)

      expect(record).to be_valid
    end
  end

  describe "cache invalidation" do
    let(:school)    { create(:school) }
    let(:classroom) { create(:classroom, school: school) }
    let(:student)   { create(:student) }

    it "invalidates school cache upon record creation" do
      expect(Rails.cache).to receive(:delete_matched)
        .with("recipient_resolver/school/#{school.id}*")

      StudentClassroom.create!(student: student, classroom: classroom)
    end

    it "invalidates school cache upon record destruction" do
      record = StudentClassroom.create!(student: student, classroom: classroom)

      expect(Rails.cache).to receive(:delete_matched)
        .with("recipient_resolver/school/#{school.id}*")

      record.destroy!
    end

    it "does not invalidate cache of another school" do
      other_school    = create(:school)
      other_classroom = create(:classroom, school: other_school)

      expect(Rails.cache).to receive(:delete_matched)
        .with("recipient_resolver/school/#{other_school.id}*")
      expect(Rails.cache).not_to receive(:delete_matched)
        .with("recipient_resolver/school/#{school.id}*")

      StudentClassroom.create!(student: student, classroom: other_classroom)
    end
  end
end