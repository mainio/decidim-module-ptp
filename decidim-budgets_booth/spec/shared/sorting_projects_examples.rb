# frozen_string_literal: true

shared_examples "ordering projects by selected option" do |selected_option|
  before do
    visit current_path
    within ".order-by" do
      expect(page).to have_css("a[data-order='random']", text: "Random order")
      page.find("a", text: selected_option).click
    end
  end

  it "lists the projects ordered by selected option" do
    within "#projects #dropdown-menu-order" do
      expect(page).to have_css("a.font-normal", text: "Random order")
      expect(page).to have_css("a.font-bold", text: selected_option)
    end

    expect(page).to have_css("#projects .budget-list .project-item:first-child", text: translated(first_project.title))
  end
end
