require 'rails_helper'

RSpec.describe Announcement, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      announcement = build(:announcement)
      expect(announcement).to be_valid
    end

    it "is invalid without a title" do
      announcement = build(:announcement, title: nil)
      expect(announcement).not_to be_valid
      expect(announcement.errors[:title]).to include("can't be blank")
    end

    it "is invalid without content" do
      announcement = build(:announcement, content: nil)
      expect(announcement).not_to be_valid
      expect(announcement.errors[:content]).to include("can't be blank")
    end

    it "is invalid without a scope" do
      announcement = build(:announcement, scope: nil)
      expect(announcement).not_to be_valid
      expect(announcement.errors[:scope]).to include("can't be blank")
    end
  end

  describe "enums" do
    it "has draft as the default status" do
      announcement = create(:announcement)
      expect(announcement.status).to eq("draft")
    end

    it "supports all statuses" do
      expect(Announcement.statuses.keys).to contain_exactly("draft", "sending", "sent")
    end

    it "supports all scopes" do
      expect(Announcement.scopes.keys).to contain_exactly("school", "classrooms", "students")
    end
  end

  describe "scopes" do
    let(:school) { create(:school) }
    let!(:draft_announcement) { create(:announcement, school: school, status: "draft") }
    let!(:sent_announcement) { create(:announcement, :sent, school: school) }

    describe ".sent" do
      it "returns only sent announcements" do
        expect(Announcement.sent).to include(sent_announcement)
        expect(Announcement.sent).not_to include(draft_announcement)
      end
    end

    describe ".drafts" do
      it "returns only draft announcements" do
        expect(Announcement.drafts).to include(draft_announcement)
        expect(Announcement.drafts).not_to include(sent_announcement)
      end
    end

    describe ".by_school" do
      it "returns only announcements for the given school" do
        other_announcement = create(:announcement)
        expect(Announcement.by_school(school.id)).to include(draft_announcement, sent_announcement)
        expect(Announcement.by_school(school.id)).not_to include(other_announcement)
      end
    end
  end

  describe "associations" do
    let(:school) { create(:school) }
    let(:announcement) { create(:announcement, school: school) }

    it "belongs to a school" do
      expect(announcement.school).to eq(school)
    end

    it "has many classrooms through announcement_classrooms" do
      classroom = create(:classroom, school: school)
      create(:announcement_classroom, announcement: announcement, classroom: classroom)
      expect(announcement.classrooms).to include(classroom)
    end

    it "has many students through announcement_students" do
      student = create(:student)
      create(:announcement_student, announcement: announcement, student: student)
      expect(announcement.students).to include(student)
    end

    it "destroys dependent delivery_logs when announcement is destroyed" do
      guardian = create(:guardian)
      create(:delivery_log, announcement: announcement, guardian: guardian)
      expect { announcement.destroy }.to change(DeliveryLog, :count).by(-1)
    end
  end

  describe "state checks" do
    it "returns true for draft? when status is draft" do
      announcement = create(:announcement, status: "draft")
      expect(announcement.draft?).to be(true)
    end

    it "returns true for sent? when status is sent" do
      announcement = create(:announcement, :sent)
      expect(announcement.sent?).to be(true)
    end
  end
end
