require 'rails_helper'

RSpec.describe AnnouncementStatsQuery, type: :query do
  let(:school) { create(:school) }
  let(:announcement) { create(:announcement, school: school) }

  subject(:query_result) { described_class.call(announcement) }

  describe ".call" do
    context "when there are no delivery logs" do
      it "returns total as zero" do
        expect(query_result[:total]).to eq(0)
      end

      it "returns read count as zero" do
        expect(query_result[:read]).to eq(0)
      end

      it "returns unread count as zero" do
        expect(query_result[:unread]).to eq(0)
      end

      it "returns read_percentage as 0.0" do
        expect(query_result[:read_percentage]).to eq(0.0)
      end

      it "returns the announcement status" do
        expect(query_result[:status]).to eq(announcement.status)
      end

      it "returns the announcement sent_at" do
        expect(query_result[:sent_at]).to eq(announcement.sent_at)
      end
    end

    context "when there are only unread delivery logs" do
      before do
        3.times { create(:delivery_log, announcement: announcement, guardian: create(:guardian), read: false) }
      end

      it "returns the correct total" do
        expect(query_result[:total]).to eq(3)
      end

      it "returns read count as zero" do
        expect(query_result[:read]).to eq(0)
      end

      it "returns the correct unread count" do
        expect(query_result[:unread]).to eq(3)
      end

      it "returns read_percentage as 0.0" do
        expect(query_result[:read_percentage]).to eq(0.0)
      end
    end

    context "when there are only read delivery logs" do
      before do
        2.times { create(:delivery_log, :read, announcement: announcement, guardian: create(:guardian)) }
      end

      it "returns the correct total" do
        expect(query_result[:total]).to eq(2)
      end

      it "returns the correct read count" do
        expect(query_result[:read]).to eq(2)
      end

      it "returns unread count as zero" do
        expect(query_result[:unread]).to eq(0)
      end

      it "returns read_percentage as 100.0" do
        expect(query_result[:read_percentage]).to eq(100.0)
      end
    end

    context "when there are both read and unread delivery logs" do
      before do
        3.times { create(:delivery_log, :read, announcement: announcement, guardian: create(:guardian)) }
        1.times { create(:delivery_log, announcement: announcement, guardian: create(:guardian), read: false) }
      end

      it "returns the correct total" do
        expect(query_result[:total]).to eq(4)
      end

      it "returns the correct read count" do
        expect(query_result[:read]).to eq(3)
      end

      it "returns the correct unread count" do
        expect(query_result[:unread]).to eq(1)
      end

      it "calculates read_percentage correctly" do
        expect(query_result[:read_percentage]).to eq(75.0)
      end
    end

    context "when the announcement has been sent" do
      let(:sent_at) { 1.hour.ago }
      let(:announcement) { create(:announcement, :sent, school: school, sent_at: sent_at) }

      it "returns the correct status" do
        expect(query_result[:status]).to eq("sent")
      end

      it "returns the correct sent_at" do
        expect(query_result[:sent_at]).to be_within(1.second).of(sent_at)
      end
    end

    context "when delivery logs belong to a different announcement" do
      let(:other_announcement) { create(:announcement, school: school) }

      before do
        create(:delivery_log, :read, announcement: other_announcement, guardian: create(:guardian))
      end

      it "does not count logs from other announcements" do
        expect(query_result[:total]).to eq(0)
      end
    end
  end
end
