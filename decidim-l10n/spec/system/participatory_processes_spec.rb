# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "ExploreParticipatoryProcesses" do
  include_context "with a component"

  let(:manifest_name) { current_manifest }

  before do
    switch_to_host(organization.host)
  end

  describe "show" do
    context "with accountability results" do
      let(:path) { decidim_participatory_process_accountability.results_path(participatory_process_slug: participatory_process.slug, component_id: component.id) }
      let(:current_manifest) { "accountability" }
      let!(:record) { create(:result, component:, start_date: Date.new(2017, 7, 12), end_date: Date.new(2017, 9, 30)) }

      it "displays the dates correctly" do
        visit path
        within(".card__list-metadata") do
          expect(page).to have_content("Jul 12 - Sep 30")
        end
      end
    end

    context "with meetings" do
      let(:current_manifest) { "meetings" }
      let(:component) { create(:meeting_component, participatory_space: participatory_process) }
      let(:start_time) { Time.zone.local(2017, 1, 13, 8, 0, 0) }
      let(:end_time) { Time.zone.local(2017, 12, 20, 15, 0, 0) }
      let!(:meeting) { create(:meeting, :not_official, :published, component:, start_time:, end_time:) }

      it "displays the dates correctly" do
        visit_component

        within "#meetings__meeting_#{meeting.id}" do
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
        end
        within(".card__list-metadata") do
          expect(page).to have_content("08:00 AM UTC")
        end
      end
    end
  end
end
