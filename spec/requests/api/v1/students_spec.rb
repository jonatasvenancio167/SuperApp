require 'rails_helper'

RSpec.describe "Api::V1::Students", type: :request do
  let(:school) { create(:school) }
  let(:headers) { { "X-School-Id" => school.id } }

  describe "GET /api/v1/students" do
    let(:classroom) { create(:classroom, school: school) }
    let!(:students) { create_list(:student, 3) }

    before do
      students.each { |s| create(:student_classroom, student: s, classroom: classroom) }
    end

    it "returns a successful response" do
      get api_v1_students_path, headers: headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(3)
    end
  end

  describe "GET /api/v1/students/:id" do
    let(:student) { create(:student) }

    it "returns the requested student" do
      get api_v1_student_path(student), headers: headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(student.id)
    end
  end
end
