require 'rails_helper'

RSpec.describe AnnouncementDispatchJob, type: :job do
  let(:school) { create(:school) }

  describe "#perform" do
    context "when the announcement does not exist" do
      it "returns without raising an error" do
        expect { described_class.new.perform("non-existent-id") }.not_to raise_error
      end

      it "does not create delivery logs" do
        expect {
          described_class.new.perform("non-existent-id")
        }.not_to change(DeliveryLog, :count)
      end
    end

    context "when the announcement is not in sending status" do
      let(:announcement) { create(:announcement, school: school, status: "draft") }

      it "returns without creating delivery logs" do
        expect {
          described_class.new.perform(announcement.id)
        }.not_to change(DeliveryLog, :count)
      end

      it "does not change the announcement status" do
        described_class.new.perform(announcement.id)
        expect(announcement.reload.status).to eq("draft")
      end
    end

    context "when the announcement is in sending status with school scope" do
      let(:announcement) { create(:announcement, school: school, scope: "school", status: "sending") }
      let(:classroom) { create(:classroom, school: school) }
      let(:student) { create(:student) }
      let(:guardian) { create(:guardian) }

      before do
        create(:student_classroom, student: student, classroom: classroom)
        create(:student_guardian, student: student, guardian: guardian)
      end

      it "creates delivery logs for all guardians of the school" do
        expect {
          described_class.new.perform(announcement.id)
        }.to change(DeliveryLog, :count).by(1)
      end

      it "marks the announcement as sent" do
        described_class.new.perform(announcement.id)
        expect(announcement.reload.status).to eq("sent")
      end

      it "creates delivery logs with read set to false" do
        described_class.new.perform(announcement.id)
        expect(DeliveryLog.last.read).to be(false)
      end

      it "does not duplicate delivery logs for the same guardian" do
        create(:delivery_log, announcement: announcement, guardian: guardian)
        expect {
          described_class.new.perform(announcement.id)
        }.not_to change(DeliveryLog, :count)
      end
    end

    context "when the announcement is in sending status with classrooms scope" do
      let(:classroom) { create(:classroom, school: school) }
      let(:announcement) { create(:announcement, school: school, scope: "classrooms", status: "sending") }
      let(:student) { create(:student) }
      let(:guardian) { create(:guardian) }

      before do
        create(:announcement_classroom, announcement: announcement, classroom: classroom)
        create(:student_classroom, student: student, classroom: classroom)
        create(:student_guardian, student: student, guardian: guardian)
      end

      it "creates delivery logs for guardians of students in the selected classrooms" do
        expect {
          described_class.new.perform(announcement.id)
        }.to change(DeliveryLog, :count).by(1)
      end

      it "marks the announcement as sent" do
        described_class.new.perform(announcement.id)
        expect(announcement.reload.status).to eq("sent")
      end
    end

    context "when the announcement is in sending status with students scope" do
      let(:announcement) { create(:announcement, school: school, scope: "students", status: "sending") }
      let(:student) { create(:student) }
      let(:guardian) { create(:guardian) }

      before do
        create(:announcement_student, announcement: announcement, student: student)
        create(:student_guardian, student: student, guardian: guardian)
      end

      it "creates delivery logs for guardians of the selected students" do
        expect {
          described_class.new.perform(announcement.id)
        }.to change(DeliveryLog, :count).by(1)
      end

      it "marks the announcement as sent" do
        described_class.new.perform(announcement.id)
        expect(announcement.reload.status).to eq("sent")
      end
    end

    context "when no recipients are found" do
      let(:announcement) { create(:announcement, school: school, scope: "school", status: "sending") }

      it "still marks the announcement as sent" do
        described_class.new.perform(announcement.id)
        expect(announcement.reload.status).to eq("sent")
      end

      it "does not create any delivery logs" do
        expect {
          described_class.new.perform(announcement.id)
        }.not_to change(DeliveryLog, :count)
      end
    end
  end
end
