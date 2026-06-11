# frozen_string_literal: true

require "spec_helper"

describe Decidim::Taxonomy do
  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, organization:, settings: component_settings) }
  let(:component_settings) { { taxonomy_filters: [taxonomy_filter.id] } }

  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: root_taxonomy) }
  let!(:postal_taxonomies) do
    (10_000..10_005).each_with_object({}) do |code, hash|
      hash[code.to_s] = create(:taxonomy, parent: root_taxonomy, name: { en: code.to_s }, code: "POSTAL_#{code}")
    end
  end
  let(:taxonomy_manager) { Decidim::BudgetsBooth::TaxonomyManager.new(component) }

  describe "#create" do
    it "clears the cache" do
      expect(taxonomy_manager.zip_codes_for(root_taxonomy)).to match_array(%w(10000 10001 10002 10003 10004 10005))

      postal_taxonomies.values.last.destroy!
      create(:taxonomy, parent: root_taxonomy, name: { en: "10006" }, code: "POSTAL_10006")
      expect(taxonomy_manager.zip_codes_for(root_taxonomy)).to match_array(%w(10000 10001 10002 10003 10004 10006))
    end
  end

  describe "#update" do
    it "clears the cache" do
      expect(taxonomy_manager.zip_codes_for(root_taxonomy)).to match_array(%w(10000 10001 10002 10003 10004 10005))

      postal_taxonomies.values.last.update!(name: { en: "10006" }, code: "POSTAL_10006")
      expect(taxonomy_manager.zip_codes_for(root_taxonomy)).to match_array(%w(10000 10001 10002 10003 10004 10006))
    end
  end

  describe "#destroy" do
    it "clears the cache" do
      expect(taxonomy_manager.zip_codes_for(root_taxonomy)).to match_array(%w(10000 10001 10002 10003 10004 10005))

      postal_taxonomies.values.last.destroy!
      expect(taxonomy_manager.zip_codes_for(root_taxonomy)).to match_array(%w(10000 10001 10002 10003 10004))
    end
  end
end
