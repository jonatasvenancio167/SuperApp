require 'rails_helper'

RSpec.describe "Api::V1::DeliveryLogs", type: :request do
  let(:school) { create(:school) }
  let(:headers) { { "X-School-Id" => school.id } }
  let(:announcement) { create(:announcement, school: school) }
  let(:guardian) { create(:guardian) }
  let!(:delivery_log) { create(:delivery_log, announcement: announcement, guardian: guardian) }

  describe "POST /api/v1/delivery_logs/:id/read" do
    it "marks the log as read" do
      post read_api_v1_delivery_log_path(delivery_log), headers: headers
      expect(response).to have_http_status(:ok)
      expect(delivery_log.reload.read).to be(true)
      expect(delivery_log.read_at).to be_present
    end
  end
end
