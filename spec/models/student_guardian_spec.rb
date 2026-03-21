# spec/models/student_guardian_spec.rb
require "rails_helper"

RSpec.describe StudentGuardian, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:student) }
    it { is_expected.to belong_to(:guardian) }
  end

  describe "validations" do
    it "is valid with student and guardian" do
      student  = create(:student)
      guardian = create(:guardian)
      record   = StudentGuardian.new(student: student, guardian: guardian)

      expect(record).to be_valid
    end

    it "does not allow the same guardian linked to the same student twice" do
      student  = create(:student)
      guardian = create(:guardian)

      StudentGuardian.create!(student: student, guardian: guardian)

      # Tests the DB constraint directly — the unique index rejects the duplicate
      expect {
        StudentGuardian.create!(student: student, guardian: guardian)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows the same guardian linked to different students" do
      student1 = create(:student)
      student2 = create(:student)
      guardian = create(:guardian)

      StudentGuardian.create!(student: student1, guardian: guardian)
      record = StudentGuardian.new(student: student2, guardian: guardian)

      expect(record).to be_valid
    end

    it "allows different guardians linked to the same student" do
      student   = create(:student)
      guardian1 = create(:guardian)
      guardian2 = create(:guardian)

      StudentGuardian.create!(student: student, guardian: guardian1)
      record = StudentGuardian.new(student: student, guardian: guardian2)

      expect(record).to be_valid
    end
  end

  describe "cache invalidation" do
    let(:school)    { create(:school) }
    let(:classroom) { create(:classroom, school: school) }
    let(:student)   { create(:student) }
    let(:guardian)  { create(:guardian) }

    before do
      StudentClassroom.create!(student: student, classroom: classroom)
    end

    it "invalidates school cache upon linkage creation" do
      expect(Rails.cache).to receive(:delete_matched)
        .with("recipient_resolver/school/#{school.id}*")

      StudentGuardian.create!(student: student, guardian: guardian)
    end

    it "invalidates school cache upon linkage destruction" do
      record = StudentGuardian.create!(student: student, guardian: guardian)

      expect(Rails.cache).to receive(:delete_matched)
        .with("recipient_resolver/school/#{school.id}*")

      record.destroy!
    end

    it "invalidates cache for all schools where the student is enrolled" do
      other_school    = create(:school)
      other_classroom = create(:classroom, school: other_school)
      StudentClassroom.create!(student: student, classroom: other_classroom)

      expect(Rails.cache).to receive(:delete_matched)
        .with("recipient_resolver/school/#{school.id}*")
      expect(Rails.cache).to receive(:delete_matched)
        .with("recipient_resolver/school/#{other_school.id}*")

      StudentGuardian.create!(student: student, guardian: guardian)
    end

    it "does not invalidate cache if the student has no linked classroom" do
      student_without_classroom = create(:student)

      expect(Rails.cache).not_to receive(:delete_matched)

      StudentGuardian.create!(student: student_without_classroom, guardian: guardian)
    end
  end
end