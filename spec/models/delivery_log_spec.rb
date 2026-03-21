require 'rails_helper'

RSpec.describe DeliveryLog, type: :model do
  let(:announcement) { create(:announcement) }
  let(:guardian) { create(:guardian) }

  describe "associations" do
    it "belongs to an announcement" do
      log = create(:delivery_log, announcement: announcement, guardian: guardian)
      expect(log.announcement).to eq(announcement)
    end

    it "belongs to a guardian" do
      log = create(:delivery_log, announcement: announcement, guardian: guardian)
      expect(log.guardian).to eq(guardian)
    end
  end

  describe "scopes" do
    let!(:read_log) { create(:delivery_log, :read, announcement: announcement, guardian: create(:guardian)) }
    let!(:unread_log) { create(:delivery_log, announcement: announcement, guardian: create(:guardian)) }

    describe ".read" do
      it "returns only read logs" do
        expect(DeliveryLog.read).to include(read_log)
        expect(DeliveryLog.read).not_to include(unread_log)
      end
    end

    describe ".unread" do
      it "returns only unread logs" do
        expect(DeliveryLog.unread).to include(unread_log)
        expect(DeliveryLog.unread).not_to include(read_log)
      end
    end
  end

  describe "#mark_as_read!" do
    let(:log) { create(:delivery_log, announcement: announcement, guardian: guardian, read: false) }

    it "marks the log as read" do
      expect { log.mark_as_read! }.to change { log.reload.read }.from(false).to(true)
    end

    it "sets read_at timestamp" do
      freeze_time = Time.current
      allow(Time).to receive(:current).and_return(freeze_time)
      log.mark_as_read!
      expect(log.reload.read_at).to be_within(1.second).of(freeze_time)
    end
  end
end
