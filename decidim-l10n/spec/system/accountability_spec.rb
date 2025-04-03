# frozen_string_literal: true

require "spec_helper"

describe "ExploreResults", versioning: true do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }
  let!(:result) { create(:result, component:, start_date: Date.new(2017, 7, 12), end_date: Date.new(2017, 9, 30)) }
  let!(:timeline_entry) { create(:timeline_entry, result:, entry_date: Date.new(2017, 8, 20)) }

  before do
    visit path
  end

  describe "index" do
    let(:path) { decidim_participatory_process_accountability.results_path(participatory_process_slug: participatory_process.slug, component_id: component.id) }

    it "shows all results for the given process and category" do
      within(".card__list-metadata") do
        expect(page).to have_content("Jul 12 - Sep 30")
      end
    end
  end

  describe "show" do
    let(:path) { decidim_participatory_process_accountability.result_path(id: result.id, participatory_process_slug: participatory_process.slug, component_id: component.id) }

    it "displays the dates correctly" do
      within(".accountability__project-aside-item", text: "Start date / End date") do
        expect(page).to have_content("Jul 12 2017 / Sep 30 2017")
      end

      within(".accountability__project-timeline-entry-attributes") do
        expect(page).to have_content("08/20/2017")
      end
    end
  end
end
