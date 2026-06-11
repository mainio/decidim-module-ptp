# frozen_string_literal: true

shared_context "with taxonomies" do
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:subtaxonomies) { create_list(:taxonomy, 3, parent: root_taxonomy, organization:) }
  let!(:first_postals) do
    [].tap do |postals|
      5.times do |i|
        code = (10_000 + i).to_s
        postals << create(:taxonomy, parent: subtaxonomies[0], name: { en: code }, code: "FIRST_#{code}")
      end
    end
  end
  let!(:second_postals) do
    [].tap do |postals|
      7.times do |i|
        code = (10_010 + i).to_s
        postals << create(:taxonomy, parent: subtaxonomies[1], name: { en: code }, code: "SECOND_#{code}")
      end
    end
  end
  let!(:third_postals) do
    [].tap do |postals|
      8.times do |i|
        code = (10_020 + i).to_s
        postals << create(:taxonomy, parent: subtaxonomies[2], name: { en: code }, code: "THIRD_#{code}")
      end
    end
  end
end

shared_context "with user data" do
  let!(:user_data) { create(:user_data, component:, user:) }
end

shared_context "with taxonomied budgets" do
  include_context "with taxonomies"

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, settings: component_settings, organization:) }
  let(:component_settings) { { taxonomy_filters: [taxonomy_filter.id] } }

  let(:taxonomy_filter) do
    create(:taxonomy_filter, root_taxonomy:).tap do |filter|
      subtaxonomies.each do |subtaxonomy|
        create(:taxonomy_filter_item, taxonomy_filter: filter, taxonomy_item: subtaxonomy)
      end
    end
  end

  let(:budgets) { create_list(:budget, 3, component:, total_budget: 100_000) }
  let!(:first_projects_set) { create_list(:project, projects_count, budget: budgets[0], budget_amount: 25_000) }
  let!(:second_projects_set) { create_list(:project, projects_count, budget: budgets[1], budget_amount: 25_000) }
  let!(:last_projects_set) { create_list(:project, projects_count, budget: budgets[2], budget_amount: 25_000) }

  before do
    # We update the description to be less than the truncation limit. To test the truncation, we update those in tests.
    attach_images(budgets)
    budgets[0].update!(description: { en: "<p>Eius officiis expedita. 55</p>" })
    budgets[1].update!(description: { en: "<p>Eius officiis expedita. 56</p>" })
    budgets[0].taxonomies << subtaxonomies
    budgets[1].taxonomies << subtaxonomies[0]
    budgets[2].taxonomies << subtaxonomies[1]
  end

  private

  def attach_images(budgets)
    city_files = ["city.jpeg", "city2.jpeg", "city3.jpeg"]
    budgets.each_with_index do |budget, ind|
      budget.update(main_image: ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset(city_files[ind])),
        filename: city_files[ind],
        content_type: "image/jpeg"
      ))
    end
  end
end

shared_context "with single scoped budget" do
  include_context "with taxonomy filters context"

  let(:component) { create(:budgets_component, settings: component_settings, organization:) }
  let(:component_settings) { { taxonomy_filters: [taxonomy_filter.id] } }

  let!(:postal_taxonomy) { create(:taxonomy, name: { en: "10004" }, parent: taxonomy, organization:) }
  let!(:budget) { create(:budget, component:, total_budget: 100_000) }
  let!(:projects_set) { create_list(:project, 3, budget:, budget_amount: 25_000) }

  before do
    budget.update!(description: { en: "<p>Eius officiis expedita. 55</p>" })
    budget.taxonomies << taxonomy

    Decidim::BudgetsBooth::TaxonomyManager.clear_cache!
  end
end

shared_context "with zip_code workflow" do
  let!(:component) do
    create(
      :budgets_component,
      settings: component_settings.merge(workflow: "zip_code"),
      organization:
    )
  end
end

shared_context "with a survey" do
  let!(:participatory_space) { component.participatory_space }
  let!(:surveys_component) { create(:surveys_component, :published, participatory_space:) }
  let!(:survey) { create(:survey, component: surveys_component) }
  let!(:questionnaire) { create(:questionnaire, questionnaire_for: survey) }
end
