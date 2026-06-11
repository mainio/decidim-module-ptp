# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::Workflows::ZipCode do
  subject { described_class.new(component, user) }

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, settings: component_settings, organization:) }
  let!(:user) { create(:user, organization:) }

  describe "#vote_allowed?" do
    include_context "with taxonomies"
    include_context "with user data"

    let(:taxonomy_filter) do
      create(:taxonomy_filter, root_taxonomy:).tap do |filter|
        subtaxonomies.each do |subtaxonomy|
          create(:taxonomy_filter_item, taxonomy_filter: filter, taxonomy_item: subtaxonomy)
        end
      end
    end
    let(:component_settings) { { taxonomy_filters: [taxonomy_filter.id] } }

    let!(:allowed_budget) { create(:budget, component:) }
    let!(:not_allowed_budget) { create(:budget, component:) }

    before do
      allowed_budget.taxonomies << subtaxonomies.first
      not_allowed_budget.taxonomies << subtaxonomies.second
      Decidim::BudgetsBooth::TaxonomyManager.clear_cache!
    end

    context "when user zip code is blank" do
      before do
        user_data.update(metadata: { zip_code: "" })
      end

      it "returns false" do
        expect(subject).not_to be_vote_allowed(not_allowed_budget, consider_progress: true)
      end
    end

    context "when user zip code presents" do
      before do
        user_data.update(metadata: { zip_code: "10004" })
      end

      it "returns false for not_allowed_budget" do
        expect(subject).not_to be_vote_allowed(not_allowed_budget, consider_progress: true)
      end

      it "returns true for allowed_budget" do
        expect(subject).to be_vote_allowed(allowed_budget, consider_progress: true)
      end
    end
  end

  describe "#budgets" do
    let(:component_settings) { {} }
    let!(:budgets) { create_list(:budget, 3, component:) }

    let(:taxonomy_manager) { instance_double(Decidim::BudgetsBooth::TaxonomyManager) }

    before do
      allow(Decidim::BudgetsBooth::TaxonomyManager).to receive(:new).with(component).and_return(taxonomy_manager)
      allow(taxonomy_manager).to receive(:user_zip_code).with(user).and_return("dummy zip_code")
      allow(taxonomy_manager).to receive(:zip_codes_for).with(budgets.first).and_return(["dummy zip_code"])
      allow(taxonomy_manager).to receive(:zip_codes_for).with(budgets.second).and_return(["dummy zip_code"])
      allow(taxonomy_manager).to receive(:zip_codes_for).with(budgets.last).and_return(["another code"])
    end

    it "returns the correct budgets list" do
      expect(subject.budgets).to include(budgets.first)
      expect(subject.budgets).to include(budgets.second)
      expect(subject.budgets).not_to include(budgets.last)
    end
  end

  describe "#highlighted?" do
    let(:component_settings) { {} }
    let!(:budgets) { create_list(:budget, 3, component:) }

    it "returs false" do
      result = subject.highlighted?(budgets.first)
      expect(result).to be_falsey
    end
  end

  describe "#disable_voting_instructions?" do
    let(:component_settings) { {} }

    it "is disabled by default" do
      expect(subject).to be_disable_voting_instructions
    end
  end

  describe "hide_image_in_popup?" do
    let(:component_settings) { {} }

    it "is disabled by default" do
      expect(subject).to be_hide_image_in_popup
    end
  end
end
