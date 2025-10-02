require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:notification) }

    it { should validate_presence_of(:title) }
  end

  describe "enums" do
    it { should define_enum_for(:kind).with_values(new_job_application: 0, application_update: 1, job_recommendation: 2, system_announcement: 3, recruiter_approved: 4, recruiter_rejected: 5, admin_approved_recruiter: 6) }
  end

  describe "scopes" do
    let!(:unread_notification) { create(:notification, :unread) }
    let!(:read_notification) { create(:notification, :read) }

    it ".unread returns notifications with read_at nil" do
      expect(Notification.unread).to include(unread_notification)
      expect(Notification.unread).not_to include(read_notification)
    end

    it ".read returns notifications with read_at present" do
      expect(Notification.read).to include(read_notification)
      expect(Notification.read).not_to include(unread_notification)
    end

    it ".recent orders notifications by created_at desc" do
      expect(Notification.recent.first).to eq(read_notification)
    end

    it ".by_kind returns notifications of a given kind" do
      kind = unread_notification.kind
      expect(Notification.by_kind(kind)).to include(unread_notification)
    end
  end

  describe "instance methods" do
    let(:notification) { create(:notification, :unread) }

    it "#read? returns false if unread" do
      expect(notification.read?).to be false
    end

    it "#unread? returns true if unread" do
      expect(notification.unread?).to be true
    end

    it "#mark_as_read! sets read_at" do
      expect { notification.mark_as_read! }.to change { notification.read_at }.from(nil)
      expect(notification.read?).to be true
      expect(notification.unread?).to be false
    end

    it "#mark_as_read! does nothing if already read" do
      notification.mark_as_read!
      read_at_time = notification.read_at
      notification.mark_as_read!
      expect(notification.read_at).to eq(read_at_time)
    end
  end
end
