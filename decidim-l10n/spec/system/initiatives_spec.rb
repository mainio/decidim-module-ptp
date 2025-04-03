# frozen_string_literal: true

require "spec_helper"

describe "ExploreInitiatives" do
  let(:organization) { create(:organization) }
  let(:state) { :published }
  let(:initiative) { create(:initiative, organization:, state:, published_at: Time.zone.local(2017, 12, 30, 15, 0, 0), signature_start_date: Time.zone.local(2017, 12, 30, 15, 0, 0), signature_end_date: Time.zone.local(2018, 1, 2, 14, 0, 0)) }

  before do
    switch_to_host(organization.host)
  end

  describe "initiative page" do
    before do
      visit decidim_initiatives.initiative_path(initiative)
    end

    it "shows the details of the given initiative" do
      within(".initiatives__card__grid-metadata-dates") do
        expect(page).to have_content("Dec 30 2017 → Jan 02 2018")
      end
    end
  end
end
