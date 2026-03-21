require 'rails_helper'

RSpec.describe ClassroomSerializer, type: :serializer do
  let(:classroom) { create(:classroom) }
  let(:result) { JSON.parse(described_class.render(classroom)) }

  it "includes the id" do
    expect(result["id"]).to eq(classroom.id)
  end

  it "includes the name" do
    expect(result["name"]).to eq(classroom.name)
  end

  it "includes the grade" do
    expect(result["grade"]).to eq(classroom.grade)
  end

  it "does not include unexpected fields" do
    expect(result.keys).to contain_exactly("id", "name", "grade")
  end
end
