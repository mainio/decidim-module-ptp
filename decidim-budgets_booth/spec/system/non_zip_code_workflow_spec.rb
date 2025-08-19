# frozen_string_literal: true

require "spec_helper"

describe "NonZipCodeWorkflow" do
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }
  let(:component) { create(:budgets_component, settings: component_settings) }
  let(:component_settings) { { workflow: "all" } }

  let(:budget) { create(:budget, component:, total_budget: 100_000) }
  let!(:project_one) { create(:project, budget:, budget_amount: 25_000) }
  let!(:project_two) { create(:project, budget:, budget_amount: 50_000) }

  context "when multiple budgets" do
    let!(:second_budget) { create(:budget, component:, total_budget: 100_000) }
    let!(:project_one) { create(:project, budget:, budget_amount: 25_000) }
    let!(:project_two) { create(:project, budget:, budget_amount: 50_000) }

    before do
      switch_to_host(organization.host)
    end

    context "when not voting" do
      before do
        visit decidim_budgets.budgets_path
        find(".card--list__item", text: translated_attribute(budget.title)).click
      end

      it_behaves_like "filtering projects" do
        let!(:projects) { [project_one, project_two] }
        let(:current_component) { component }
        let(:voting_mode) { false }
      end

      it "explores the budgets" do
        expect(page).to have_content("2 projects")
        expect(page).to have_content("Back to budgets")
        expect(page).to have_button("Start voting")
      end

      context "when ordering by highest cost" do
        it_behaves_like "ordering projects by selected option", "Highest cost" do
          let(:first_project) { project_two }
          let(:last_project) { project_one }
        end
      end

      context "when ordering by lowest cost" do
        it_behaves_like "ordering projects by selected option", "Lowest cost" do
          let(:first_project) { project_one }
          let(:last_project) { project_two }
        end
      end
    end

    context "when entering voting" do
      context "when user is not signed_in" do
        before do
          visit decidim_budgets.budget_voting_index_path(budget)
        end

        it "sends the user to the sign in page" do
          expect(page).to have_current_path "/users/sign_in"
        end
      end

      context "when authorized" do
        before do
          sign_in user
          visit decidim_budgets.budget_voting_index_path(budget)
        end

        it "enters the voting booth" do
          expect(page).to have_content("You are now in the voting booth.")
          expect(page).to have_current_path(decidim_budgets.budget_voting_index_path(budget))
        end

        it "adds and removes projects" do
          expect(page).to have_css(".project-vote-button", count: 2)

          within "#project-#{project_one.id}-item" do
            find(".button.project-vote-button", match: :first).click
          end
          expect(page).to have_css(".button.project-vote-button", text: "Choose", count: 1, visible: :visible)
          expect(page).to have_css(".button.project-vote-button", text: "Remove", count: 1, visible: :visible)

          find(".button.project-vote-button", text: "Choose").click

          expect(page).to have_css(".button.project-vote-button", text: "Remove", count: 2, visible: :visible)

          find(".button.project-vote-button", text: "Remove", match: :first).click

          expect(page).to have_css(".button.project-vote-button", text: "Choose", count: 1, visible: :visible)
          expect(page).to have_css(".button.project-vote-button", text: "Remove", count: 1, visible: :visible)
        end

        context "when full-text is enabled" do
          before do
            component.update(settings: { show_full_description_on_listing_page: true })
            sign_in user
            visit decidim_budgets.budget_voting_index_path(budget)
          end

          it "shows complete text for the project" do
            within("#project-#{project_one.id}-item") do
              expect(page).to have_no_button("Read more")
              expect(page).to have_no_content(/.*\.{3}$/)
              expect(page).to have_content(strip_tags(translated(project_one.description)))
            end
          end
        end

        it_behaves_like "filtering projects" do
          let!(:projects) { [project_one, project_two] }
          let(:current_component) { component }
          let(:voting_mode) { false }
        end

        context "when ordering by highest cost" do
          it_behaves_like "ordering projects by selected option", "Highest cost" do
            let(:first_project) { project_two }
            let(:last_project) { project_one }
          end
        end

        context "when ordering by lowest cost" do
          it_behaves_like "ordering projects by selected option", "Lowest cost" do
            let(:first_project) { project_one }
            let(:last_project) { project_two }
          end
        end

        describe "when voting" do
          let!(:second_budget) { create(:budget, component:, total_budget: 100_000) }
          let!(:second_budgets_project) { create(:project, budget: second_budget, budget_amount: 75_000) }

          before do
            sign_in user
          end

          describe "complete voting" do
            context "when maximum_budgets_to_vote_on is set to zero" do
              let!(:order) { create(:order, user:, budget: second_budget) }

              before do
                order.projects << second_budgets_project
                order.checked_out_at = Time.current
                order.save
              end

              it "shows a default completion text when vote_completed_content is nil" do
                vote_for_this(budget)

                expect(page).to have_content("Your vote for #{translated_attribute(budget.title)} has been registered. You can continue voting in other budgets or log out.")
              end

              it "shows the completion text that is set to vote_completed_content" do
                component.update!(settings: component_settings.merge(vote_completed_content: { en: "<p>Some dummy text</p>" }))
                vote_for_this(budget)

                expect(page).to have_content("You successfully completed your votes")
                expect(page).to have_content("Some dummy text")
              end
            end

            context "when maximum_budgets_to_vote_on is set" do
              before do
                component.update!(settings: component_settings.merge(vote_completed_content: { en: "<p>Some dummy text</p>" }, maximum_budgets_to_vote_on: 1))
              end

              it "shows the completed message" do
                vote_for_this(budget)
                expect(page).to have_css("div#vote-completed", count: 1)

                expect(page).to have_content("You successfully completed your votes")
                expect(page).to have_content("Some dummy text")
              end
            end
          end
        end
      end
    end
  end

  context "when one budget" do
    before do
      switch_to_host(organization.host)
    end

    context "when visiting the budgets list" do
      before do
        sign_in user
        visit decidim_budgets.budgets_path
      end

      it "redirects the user to projects list" do
        expect(page).to have_current_path(decidim_budgets.budget_projects_path(budget))
        expect(page).to have_button("Start voting")
        expect(page).to have_css(".budget-list__item", count: 2)
      end
    end
  end

  private

  def vote_for_this(_budget)
    page.all(".button.project-vote-button").each(&:click)
    click_on "I am ready"
    click_on "Confirm"
  end
end
