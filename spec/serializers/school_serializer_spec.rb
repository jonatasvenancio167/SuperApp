require 'rails_helper'

RSpec.describe SchoolSerializer, type: :serializer do
  let(:school) { create(:school) }
  let(:result) { JSON.parse(described_class.render(school)) }

  it "includes the id" do
    expect(result["id"]).to eq(school.id)
  end

  it "includes the name" do
    expect(result["name"]).to eq(school.name)
  end

  it "includes the code" do
    expect(result["code"]).to eq(school.code)
  end

  it "does not include unexpected fields" do
    expect(result.keys).to contain_exactly("id", "name", "code")
  end
end
