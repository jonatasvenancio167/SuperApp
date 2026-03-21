require 'rails_helper'

RSpec.describe "Api::V1::Guardians", type: :request do
  let(:school) { create(:school) }
  let(:headers) { { "X-School-Id" => school.id } }

  describe "GET /api/v1/guardians" do
    let!(:guardians) { create_list(:guardian, 3) }

    it "returns a successful response" do
      get api_v1_guardians_path, headers: headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(3)
    end
  end

  describe "GET /api/v1/guardians/:id" do
    let(:guardian) { create(:guardian) }

    it "returns the requested guardian" do
      get api_v1_guardian_path(guardian), headers: headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(guardian.id)
    end
  end
end
