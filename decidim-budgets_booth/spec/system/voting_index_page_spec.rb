# frozen_string_literal: true

require "spec_helper"

describe "VotingIndexPage" do
  include_context "with scoped budgets"

  let(:projects_count) { 10 }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:first_budget) { budgets.first }
  let(:second_budget) { budgets.second }
  let(:active_step_id) { component.participatory_space.active_step.id }

  before do
    switch_to_host(organization.host)
  end

  context "when no user_data" do
    before do
      component.update(settings: component_settings.merge(workflow: "zip_code"))
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it_behaves_like "ensure user data"
  end

  context "when not allowed to vote that budget" do
    let!(:user_data) { create(:user_data, component:, user:) }

    before do
      component.update(settings: component_settings.merge(workflow: "zip_code"))
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it_behaves_like "not allowable voting"
  end

  context "when voted to that budget" do
    let!(:user_data) { create(:user_data, component:, user:) }
    let!(:order) { create(:order, :with_projects, user:, budget: first_budget) }

    before do
      component.update(settings: component_settings.merge(workflow: "zip_code"))
      order.update!(checked_out_at: Time.current)
      user_data.update!(metadata: { zip_code: "10004" })
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it "redirects the user to the budgets page" do
      expect(page).to have_current_path(decidim_budgets.budget_projects_path(first_budget))
      within_flash_messages do
        expect(page).to have_content "You have already voted for this budget."
      end
    end
  end

  describe "voting" do
    let!(:user_data) { create(:user_data, component:, user:) }

    before do
      component.update(settings: component_settings.merge(workflow: "zip_code", projects_per_page: 5))
      user_data.update!(metadata: { zip_code: "10004" })
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it_behaves_like "cancel voting"

    it "renders the page correctly" do
      expect(page).to have_content("You are now in the voting booth.")
      expect(page).to have_content("You decide the #{first_budget.title["en"]} budget")
      expect(page).to have_button("Cancel voting")
      expect(page).to have_content("You can allocate €100,000 to different proposals.")
      expect(page).to have_css(".button.project-vote-button", count: 5)
    end

    describe "budget summary" do
      before do
        find(".project-vote-button", match: :first).click
      end

      it "updates budget summary" do
        within ".budget-summary__total" do
          expect(page).to have_content("€100,000")
        end
        expect(page).to have_content("Budget left:\n€75,000")
        within "#projects form.new_filter[data-filters]" do
          expect(page).to have_css("span", text: "Added")
          expect(page).to have_css("span", text: "1")
        end

        all(".project-vote-button")[1].click

        expect(page).to have_content("Budget left:\n€50,000")

        within "#projects form.new_filter[data-filters]" do
          expect(page).to have_css("span", text: "Added")
          expect(page).to have_css("span", text: "2")
        end

        all(".project-vote-button")[1].click

        expect(page).to have_content("Budget left:\n€75,000")
        within "#projects form.new_filter[data-filters]" do
          expect(page).to have_css("span", text: "Added")
          expect(page).to have_css("span", text: "1")
        end
      end

      context "when selected projects updated" do
        it "updates budget summary" do
          within "#projects" do
            expect(page).to have_css(".project-vote-button", text: "Remove", count: 1)
          end

          find('button[data-dialog-open="selected-projects"]').click
          expect(page).to have_css("#selected-projects")

          within "#selected-projects" do
            expect(page).to have_css(".h2", text: "Your selection for the vote")
            expect(page).to have_css("#current-choices")

            click_on "Remove"
            expect(page).to have_content("You have no chosen proposals")
            find('button[data-dialog-close="selected-projects"]', match: :first).click
          end

          within "#projects" do
            expect(page).to have_no_css(".project-vote-button", text: "Remove")
          end
        end
      end
    end

    it "paginates the projects" do
      expect(page).to have_css(".budget-list .budget-list__item", count: 5)
      find("li[data-page]", text: "2").click
      expect(page).to have_css(".budget-list .budget-list__item", count: 5)
    end

    it "adds and removes projects" do
      project1 = page.all(".budget-list .budget-list__item")[0]
      expect(page).to have_css(".button.project-vote-button", count: 5)

      within project1 do
        find(".button.project-vote-button").click
      end
      expect(page).to have_css(".button.project-vote-button", exact_text: "Choose", count: 4)
      expect(page).to have_css(".button.project-vote-button", text: "Remove", count: 1)

      find(".button.project-vote-button", text: "Remove").click
      expect(page).to have_css(".button.project-vote-button", exact_text: "Choose", count: 5)
    end

    describe "filtering projects" do
      let!(:categories) { create_list(:category, 3, participatory_space: component.participatory_space) }
      let(:current_projects) { first_budget.projects }

      it "allows searching by text" do
        project = current_projects.first
        within ".filter-search" do
          fill_in "filter[search_text_cont]", with: translated(project.title)

          find("[type='submit']").click
        end

        within "#projects" do
          expect(page).to have_css(".budget-list .budget-list__item", count: 1)
          expect(page).to have_content(decidim_html_escape(translated(project.title)))
        end
      end

      it "allows filtering by scope" do
        project = current_projects.first
        project.scope = first_budget.scope
        project.save
        visit current_path

        within "#panel-dropdown-menu-scope" do
          uncheck "All"
          label = find("label", text: decidim_sanitize(translated(first_budget.scope.name)))
          checkbox = label.find('input[type="checkbox"]')
          checkbox.check
        end

        within "#projects" do
          expect(page).to have_css(".budget-list .budget-list__item", count: 1)
          expect(page).to have_content(decidim_html_escape(translated(project.title)))
        end
      end

      it "allows filtering by category" do
        project = current_projects.first
        category = categories.first
        project.category = category
        project.save

        visit current_path
        within "#dropdown-menu-filters" do
          check("filter[with_any_category][]", option: category.id)
        end

        within "#projects" do
          expect(page).to have_css(".budget-list .budget-list__item", count: 1)
          expect(page).to have_content(decidim_html_escape(translated(project.title)))
        end
      end
    end

    describe "#vote_success_content" do
      before do
        first_budget.update!(total_budget: 26_000)
      end

      context "when vote_success_content is not set" do
        before do
          visit current_path
          vote_budget!
        end

        it "shows a default success content text" do
          expect(page).to have_content("Your vote for #{translated(first_budget.title)} has been registered. You can continue voting in other budgets or log out.")
          expect(page).to have_current_path(decidim_budgets.status_budget_order_path(first_budget))
        end
      end

      context "when vote success is set" do
        before do
          component.update!(settings: component_settings.merge(workflow: "zip_code", vote_success_content: { en: "<p>Some dummy text</p>" }))
          visit current_path
          vote_budget!
        end

        it "shows the success message set" do
          expect(page).to have_content("You have voted #{translated(first_budget.title)} successfully")
          expect(page).to have_css("p", text: "Some dummy text")
          expect(page).to have_current_path(decidim_budgets.status_budget_order_path(first_budget))
        end
      end
    end

    describe "redirect after completing votes" do
      let!(:order) { create(:order, user:, budget: second_budget) }

      before do
        first_budget.update!(total_budget: 26_000)
        second_budget.update!(total_budget: 26_000)
        order.checked_out_at = Time.current
        order.projects << second_budget.projects.first
        order.save!
      end

      context "when vote success URL is not set" do
        before do
          visit current_path
          vote_budget!
        end

        it "redirects to the status path" do
          expect(page).to have_current_path(decidim_budgets.status_budget_order_path(first_budget))
        end
      end

      context "when vote success URL is set" do
        include_context "with a survey"
        before do
          component.update!(settings: component_settings.merge(workflow: "zip_code", vote_completed_content: { en: "<p>Completed voting dummy text</p>" }, vote_success_url: main_component_path(surveys_component)))
          visit current_path
          vote_budget!
        end

        it "shows the modal" do
          expect(page).to have_current_path(main_component_path(surveys_component))
          expect(page).to have_css("#vote-completed")
          within "#vote-completed" do
            expect(page).to have_content("You successfully completed your votes")
            expect(page).to have_content("Completed voting dummy text")
          end
        end
      end

      context "when non-zipcode workflow" do
        let!(:second_order) { create(:order, user:, budget: budgets.last) }
        let(:third_budget) { budgets.last }

        include_context "with a survey"
        before do
          third_budget.update!(total_budget: 26_000)
          second_order.checked_out_at = Time.current
          second_order.projects << third_budget.projects.first
          second_order.save!
          component.update!(settings: component_settings.merge(workflow: "all", vote_completed_content: { en: "<p>Completed voting dummy text</p>" }, vote_success_url: main_component_path(surveys_component)))
          visit current_path
          non_zipcode_vote_budget!
        end

        it "shows the modal" do
          expect(page).to have_current_path(main_component_path(surveys_component))

          expect(page).to have_css("#vote-completed")
          within "#vote-completed" do
            expect(page).to have_content("You successfully completed your votes")
            expect(page).to have_content("Completed voting dummy text")
          end
        end
      end
    end

    context "when maximum budget exceeds" do
      before do
        first_budget.update!(total_budget: 24_999)
        refresh
        find(".project-vote-button", match: :first).click
      end

      it "popups maximum error notice" do
        expect(page).to have_css("#budget-excess")

        within ".budget-summary__total" do
          expect(page).to have_content("You can allocate €24,999 to different proposals.")
        end

        expect(page).to have_content("Maximum budget exceeded")
      end
    end

    context "when highest cost" do
      before { first_budget.projects.second.update!(budget_amount: 30_000) }

      it_behaves_like "ordering projects by selected option", "Highest cost" do
        let(:first_project) { first_budget.projects.second }
      end
    end

    context "when lowest cost" do
      before { first_budget.projects.second.update!(budget_amount: 20_000) }

      it_behaves_like "ordering projects by selected option", "Lowest cost" do
        let(:first_project) { first_budget.projects.second }
      end
    end

    context "when casting vote" do
      before do
        first_budget.update!(total_budget: 26_000)
        visit current_path
        find(".button.project-vote-button", match: :first).click
        click_on "Vote"
      end

      it "renders the info" do
        within "#budget-confirm" do
          expect(page).to have_content("These are the projects you have chosen to be part of the budget.")
          expect(page).to have_css("strong", text: "€25,000", count: 1)
          expect(page).to have_button("Confirm")
          expect(page).to have_button("Cancel")
          click_on("Cancel")
        end
        expect(page).to have_current_path(decidim_budgets.budget_voting_index_path(first_budget))
      end
    end

    describe "#show_full_description_on_listing_page" do
      let(:projects_count) { 1 }
      let(:project) { first_budget.projects.first }

      before do
        project.update!(description: Decidim::Faker::Localized.sentence(word_count: 20))
      end

      context "when not set" do
        before do
          visit current_path
        end

        it "does not show complete description by default" do
          within("#project-#{project.id}-item") do
            expect(page).to have_content(decidim_html_escape(translated(project.title)))
            expect(page).to have_content(decidim_html_escape(translated(project.description))[0..15])
          end
        end
      end

      context "when set" do
        before do
          component.update!(settings: component_settings.merge(workflow: "zip_code", show_full_description_on_listing_page: true))
          visit current_path
        end

        it "does not show complete description by default" do
          within("#project-#{project.id}-item") do
            expect(page).to have_no_button("button", text: decidim_sanitize(translated(project.title)))
            expect(page).to have_no_button("Read more")
            expect(page).to have_no_content(/.*\.{3}$/)
            expect(page).to have_content(decidim_sanitize(translated(project.description)))
          end
        end
      end
    end
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def budget_path(budget)
    decidim_budgets.budget_path(budget.id)
  end

  def visit_budget(budget)
    visit decidim_budgets.budget_voting_index_path(budget)
  end

  def vote_budget!
    find(".project-vote-button", match: :first).click
    click_on "Vote"
    click_on "Confirm"
  end

  def non_zipcode_vote_budget!
    find(".project-vote-button", match: :first).click
    click_on "I am ready"
    click_on "Confirm"
  end
end
