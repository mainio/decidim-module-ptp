# frozen_string_literal: true

require "spec_helper"

describe "ExploreMeetings", :slow do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:start_time) { Time.zone.local(2017, 1, 13, 8, 0, 0) }
  let(:end_time) { Time.zone.local(2017, 12, 20, 15, 0, 0) }
  let!(:meeting) { create(:meeting, :not_official, :published, component:, start_time:, end_time:) }

  # before do
  #   # Required for the link to be pointing to the correct URL with the server
  #   # port since the server port is not defined for the test environment.
  #   # allow(ActionMailer::Base).to receive(:default_url_options).and_return(port: Capybara.server_port)
  #   # component_scope = create :scope, parent: participatory_process.scope
  #   # component_settings = component["settings"]["global"].merge!(scopes_enabled: true, scope_id: component_scope.id)
  #   # component.update!(settings: component_settings)
  # end

  before do
    component.update!(settings: { maps_enabled: false })
  end

  describe "index" do
    before do
      visit_component
    end

    it "shows the meeting date correctly on the card" do
      within("#meetings__meeting_#{meeting.id}") do
        within ".card__calendar" do
          within ".card__calendar-month" do
            expect(page).to have_content("JAN")
          end

          within ".card__calendar-day" do
            expect(page).to have_content("13")
          end

          within ".card__calendar-year" do
            expect(page).to have_content("2017")
          end
        end
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
