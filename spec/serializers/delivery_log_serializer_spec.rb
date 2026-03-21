require 'rails_helper'

RSpec.describe DeliveryLogSerializer, type: :serializer do
  let(:announcement) { create(:announcement) }
  let(:guardian) { create(:guardian) }
  let(:delivery_log) { create(:delivery_log, announcement: announcement, guardian: guardian) }
  let(:result) { JSON.parse(described_class.render(delivery_log)) }

  it "includes the id" do
    expect(result["id"]).to eq(delivery_log.id)
  end

  it "includes the read flag" do
    expect(result["read"]).to eq(delivery_log.read)
  end

  it "includes created_at" do
    expect(result["created_at"]).to be_present
  end

  it "includes the guardian association" do
    expect(result["guardian"]).to include(
      "id"    => guardian.id,
      "name"  => guardian.name,
      "email" => guardian.email
    )
  end

  context "when the log is unread" do
    it "returns read_at as nil" do
      expect(result["read_at"]).to be_nil
    end
  end

  context "when the log is read" do
    let(:delivery_log) { create(:delivery_log, :read, announcement: announcement, guardian: guardian) }

    it "returns read as true" do
      expect(result["read"]).to be(true)
    end

    it "returns read_at as a timestamp" do
      expect(result["read_at"]).to be_present
    end
  end
end
