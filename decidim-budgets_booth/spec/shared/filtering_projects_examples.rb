# frozen_string_literal: true

shared_examples "filtering projects" do
  let!(:project) { projects.first }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:subtaxonomies) { create_list(:taxonomy, 3, parent: root_taxonomy, organization:) }
  let!(:taxonomy_filter) do
    create(:taxonomy_filter, root_taxonomy:).tap do |filter|
      subtaxonomies.each do |subtaxonomy|
        create(:taxonomy_filter_item, taxonomy_filter: filter, taxonomy_item: subtaxonomy)
      end
    end
  end

  before do
    current_component.update!(settings: current_component.settings.to_h.merge(taxonomy_filters: [taxonomy_filter.id]))
  end

  context "when filtering" do
    it "allows searching by text" do
      within ".filter-search" do
        fill_in "filter[search_text_cont]", with: translated(project.title)

        find('button[aria-label="Search among Projects"]').click
      end

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(decidim_html_escape(translated(project.title)))
      end
    end

    it "allows filtering by taxonomy" do
      taxonomy = subtaxonomies.first
      project.taxonomies = [taxonomy]
      project.save

      visit_budget
      within "[id^='panel-dropdown-menu-taxonomy']" do
        uncheck "All"
        find(:css, "input[type='checkbox'][value='#{subtaxonomies.first.id}']").set(true)
      end

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(decidim_html_escape(translated(project.title)))
      end
    end
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def visit_budget
    page.visit decidim_budgets.budget_projects_path(budget)
  end
end
