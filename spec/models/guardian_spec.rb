require 'rails_helper'

RSpec.describe Guardian, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      guardian = build(:guardian)
      expect(guardian).to be_valid
    end

    it "is invalid without a name" do
      guardian = build(:guardian, name: nil)
      expect(guardian).not_to be_valid
      expect(guardian.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an email" do
      guardian = build(:guardian, email: nil)
      expect(guardian).not_to be_valid
      expect(guardian.errors[:email]).to include("can't be blank")
    end

    it "is invalid with a duplicate email" do
      create(:guardian, email: "parent@example.com")
      guardian = build(:guardian, email: "parent@example.com")
      expect(guardian).not_to be_valid
      expect(guardian.errors[:email]).to include("has already been taken")
    end
  end

  describe "associations" do
    let(:guardian) { create(:guardian) }

    it "has many students through student_guardians" do
      student1 = create(:student)
      student2 = create(:student)
      create(:student_guardian, student: student1, guardian: guardian)
      create(:student_guardian, student: student2, guardian: guardian)
      expect(guardian.students).to include(student1, student2)
    end

    it "has many delivery_logs" do
      announcement = create(:announcement)
      log1 = create(:delivery_log, guardian: guardian, announcement: announcement)
      expect(guardian.delivery_logs).to include(log1)
    end

    it "destroys dependent delivery_logs when guardian is destroyed" do
      announcement = create(:announcement)
      create(:delivery_log, guardian: guardian, announcement: announcement)
      expect { guardian.destroy }.to change(DeliveryLog, :count).by(-1)
    end
  end
end
