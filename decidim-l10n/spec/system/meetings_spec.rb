# frozen_string_literal: true

require "spec_helper"

describe "ExploreMeetings", :slow do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:start_time) { Time.zone.local(2017, 1, 13, 8, 0, 0) }
  let(:end_time) { Time.zone.local(2017, 12, 20, 15, 0, 0) }
  let!(:meeting) { create(:meeting, :not_official, :published, component:, start_time:, end_time:) }
  let(:coordinates) { [meeting.latitude, meeting.longitude] }

  before do
    component.update!(settings: { maps_enabled: false })
    stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body: "")
    stub_geocoding_coordinates(coordinates)
    # Required for the link to be pointing to the correct URL with the server
    # port since the server port is not defined for the test environment.
    allow(ActionMailer::Base).to receive(:default_url_options).and_return(port: Capybara.server_port)
  end

  describe "index" do
    before do
      visit_component
    end

    it "shows the meeting date correctly on the card" do
      within("#meetings__meeting_#{meeting.id}") do
        within ".card__list-metadata" do
          expect(page).to have_content("08:00 AM UTC")
        end
      end
    end
  end

  describe "show" do
    before do
      visit resource_locator(meeting).path
    end

    it "shows all meeting info" do
      within(".meeting__calendar-container") do
        within ".meeting__calendar-month" do
          expect(page).to have_content("JAN")
          expect(page).to have_css(".meeting__calendar-separator", text: "-")
          expect(page).to have_content("DEC")
        end

        within ".meeting__calendar-day" do
          expect(page).to have_content("13")
          expect(page).to have_css(".meeting__calendar-separator", text: "-")
          expect(page).to have_content("20")
        end

        within ".meeting__calendar-year" do
          expect(page).to have_content("2017")
        end
      end
    end
  end
end
