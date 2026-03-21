require 'rails_helper'

RSpec.describe "Api::V1::Announcements", type: :request do
  let(:school) { create(:school) }
  let(:headers) { { "X-School-Id" => school.id } }

  describe "GET /api/v1/announcements" do
    let!(:announcements) { create_list(:announcement, 3, school: school) }
    let(:other_school_announcement) { create(:announcement) }

    it "returns a successful response" do
      get api_v1_announcements_path, headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "returns only announcements from the current school" do
      get api_v1_announcements_path, headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response["data"].size).to eq(3)
      expect(json_response["data"].map { |a| a["id"] }).not_to include(other_school_announcement.id)
    end
  end

  describe "GET /api/v1/announcements/:id" do
    let(:announcement) { create(:announcement, school: school) }

    it "returns a successful response" do
      get api_v1_announcement_path(announcement), headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "returns the requested announcement" do
      get api_v1_announcement_path(announcement), headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(announcement.id)
    end

    it "returns unauthorized if the announcement is from another school" do
      other_announcement = create(:announcement)
      get api_v1_announcement_path(other_announcement), headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/announcements" do
    let(:valid_params) do
      {
        announcement: {
          title: "Test Announcement",
          content: "This is a test announcement content.",
          scope: "school"
        }
      }
    end

    it "creates a new announcement" do
      expect {
        post api_v1_announcements_path, params: valid_params, headers: headers
      }.to change(Announcement, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns errors with invalid params" do
      post api_v1_announcements_path, params: { announcement: { title: "" } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/announcements/:id" do
    let(:announcement) { create(:announcement, school: school, status: "draft") }

    it "updates the announcement" do
      patch api_v1_announcement_path(announcement), params: { announcement: { title: "Updated Title" } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(announcement.reload.title).to eq("Updated Title")
    end

    it "returns error when updating a sent announcement" do
      sent_announcement = create(:announcement, :sent, school: school)
      patch api_v1_announcement_path(sent_announcement), params: { announcement: { title: "New Title" } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to be_present
    end
  end

  describe "DELETE /api/v1/announcements/:id" do
    let!(:announcement) { create(:announcement, school: school) }

    it "deletes the announcement" do
      expect {
        delete api_v1_announcement_path(announcement), headers: headers
      }.to change(Announcement, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/v1/announcements/:id/send" do
    let(:announcement) { create(:announcement, school: school, status: "draft") }

    context "when recipients are configured" do
      it "sends the announcement successfully" do
        post send_api_v1_announcement_path(announcement), headers: headers
        expect(response).to have_http_status(:accepted)
        expect(announcement.reload.status).to eq("sending")
      end
    end

    context "when recipients are not configured" do
      let(:announcement_classrooms) { create(:announcement, school: school, scope: "classrooms") }

      it "returns unprocessable entity" do
        post send_api_v1_announcement_path(announcement_classrooms), headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /api/v1/announcements/:id/stats" do
    let(:announcement) { create(:announcement, school: school) }

    it "returns stats for the announcement" do
      get stats_api_v1_announcement_path(announcement), headers: headers
      expect(response).to have_http_status(:ok)
    end
  end
end
