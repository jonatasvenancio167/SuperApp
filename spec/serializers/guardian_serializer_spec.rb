require 'rails_helper'

RSpec.describe GuardianSerializer, type: :serializer do
  let(:guardian) { create(:guardian) }
  let(:result) { JSON.parse(described_class.render(guardian)) }

  it "includes the id" do
    expect(result["id"]).to eq(guardian.id)
  end

  it "includes the name" do
    expect(result["name"]).to eq(guardian.name)
  end

  it "includes the email" do
    expect(result["email"]).to eq(guardian.email)
  end

  it "does not include unexpected fields" do
    expect(result.keys).to contain_exactly("id", "name", "email")
  end
end
