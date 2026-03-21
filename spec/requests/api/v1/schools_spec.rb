require 'rails_helper'

RSpec.describe "Api::V1::Schools", type: :request do
  let!(:school) { create(:school) }
  let(:headers) { { "X-School-Id" => school.id } }

  describe "GET /api/v1/schools" do
    it "returns a successful response" do
      get api_v1_schools_path, headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/schools/:id" do
    it "returns the requested school" do
      get api_v1_school_path(school), headers: headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(school.id)
    end
  end
end
