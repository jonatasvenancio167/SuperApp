require 'rails_helper'

RSpec.describe "Api::V1::Classrooms", type: :request do
  let(:school) { create(:school) }
  let(:headers) { { "X-School-Id" => school.id } }

  describe "GET /api/v1/classrooms" do
    let!(:classrooms) { create_list(:classroom, 3, school: school) }

    it "returns a successful response" do
      get api_v1_classrooms_path, headers: headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(3)
    end
  end

  describe "GET /api/v1/classrooms/:id" do
    let(:classroom) { create(:classroom, school: school) }

    it "returns the requested classroom" do
      get api_v1_classroom_path(classroom), headers: headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(classroom.id)
    end
  end
end
