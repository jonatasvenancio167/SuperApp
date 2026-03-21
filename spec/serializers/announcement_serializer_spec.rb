 require 'rails_helper'

RSpec.describe AnnouncementSerializer, type: :serializer do
  let(:school) { create(:school) }
  let(:announcement) { create(:announcement, school: school) }

  describe "default view" do
    let(:result) { JSON.parse(described_class.render(announcement)) }

    it "includes the id" do
      expect(result["id"]).to eq(announcement.id)
    end

    it "includes the title" do
      expect(result["title"]).to eq(announcement.title)
    end

    it "includes the content" do
      expect(result["content"]).to eq(announcement.content)
    end

    it "includes the scope" do
      expect(result["scope"]).to eq(announcement.scope)
    end

    it "includes the status" do
      expect(result["status"]).to eq(announcement.status)
    end

    it "includes sent_at" do
      expect(result).to have_key("sent_at")
    end

    it "includes attachment_url" do
      expect(result).to have_key("attachment_url")
    end

    it "includes created_at and updated_at" do
      expect(result).to have_key("created_at")
      expect(result).to have_key("updated_at")
    end

    it "includes the nested school association" do
      expect(result["school"]).to include(
        "id"   => school.id,
        "name" => school.name,
        "code" => school.code
      )
    end

    it "does not include stats in the default view" do
      expect(result).not_to have_key("stats")
    end

    it "does not include classrooms in the default view" do
      expect(result).not_to have_key("classrooms")
    end
  end

  describe ":with_stats view" do
    let(:result) { JSON.parse(described_class.render(announcement, view: :with_stats)) }

    context "with no delivery logs" do
      it "includes stats with zero counts" do
        expect(result["stats"]).to include(
          "total"          => 0,
          "read"           => 0,
          "unread"         => 0,
          "read_percentage" => 0.0
        )
      end
    end

    context "with read and unread delivery logs" do
      before do
        2.times { create(:delivery_log, :read, announcement: announcement, guardian: create(:guardian)) }
        1.times { create(:delivery_log, announcement: announcement, guardian: create(:guardian), read: false) }
      end

      it "includes correct stats counts" do
        expect(result["stats"]["total"]).to eq(3)
        expect(result["stats"]["read"]).to eq(2)
        expect(result["stats"]["unread"]).to eq(1)
        expect(result["stats"]["read_percentage"]).to eq(66.67)
      end
    end

    it "includes the classrooms association" do
      classroom = create(:classroom, school: school)
      create(:announcement_classroom, announcement: announcement, classroom: classroom)
      expect(result["classrooms"]).to be_an(Array)
      expect(result["classrooms"].first).to include("id" => classroom.id)
    end
  end
end
