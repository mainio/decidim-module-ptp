# frozen_string_literal: true

require "spec_helper"

describe "Non zip code workflow", type: :system do
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }
  let(:component) { create(:budgets_component, settings: component_settings) }
  let(:component_settings) { { workflow: "all" } }

  let(:budget) { create(:budget, component:, total_budget: 100_000) }
  let!(:project1) { create(:project, budget:, budget_amount: 25_000) }
  let!(:project2) { create(:project, budget:, budget_amount: 50_000) }

  context "when multiple budgets" do
    let!(:second_budget) { create(:budget, component:, total_budget: 100_000) }
    let!(:project1) { create(:project, budget:, budget_amount: 25_000) }
    let!(:project2) { create(:project, budget:, budget_amount: 50_000) }

    before do
      switch_to_host(organization.host)
    end

    context "when not voting" do
      before do
        visit decidim_budgets.budgets_path
        find(".card--list__item .h3", text: translated(budget.title)).click
      end

      it_behaves_like "filtering projects" do
        let!(:projects) { [project1, project2] }
        let(:current_component) { component }
        let(:voting_mode) { false }
      end

      it "explores the budgets" do
        expect(page).to have_content("Projects for")
        expect(page).to have_content("Start adding projects")
        expect(page).to have_no_content("Back to budgets")
      end

      context "when ordering by highest cost" do
        it_behaves_like "ordering projects by selected option", "Highest cost" do
          let(:first_project) { project2 }
          let(:last_project) { project1 }
        end
      end

      context "when ordering by lowest cost" do
        it_behaves_like "ordering projects by selected option", "Lowest cost" do
          let(:first_project) { project1 }
          let(:last_project) { project2 }
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
          within_flash_messages do
            expect(page).to have_content "You need to login first."
          end
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
          expect(page).to have_css(".button.project-vote-button", count: 2)

          within "#project-#{project1.id}-item" do
            find(".button.project-vote-button", match: :first).click
          end
          expect(page).to have_css(".button.project-vote-button", exact_text: "Add", count: 1, visible: :visible)
          expect(page).to have_css(".button.project-vote-button", text: "Added", count: 1, visible: :visible)
          within "#voting-help" do
            find("[data-dialog-close='voting-help']", match: :first).click
          end
          within "#project-#{project2.id}-item" do
            header = page.all("button")[0].text
            first_project_title = find("div.card__list-title").text
            click_on first_project_title
            expect(page).to have_content(header)
          end
          within "#project-modal-#{project2.id}" do
            find(".button.project-vote-button").click
            expect(page).to have_css(".button.project-vote-button", text: "Added", count: 1, visible: :visible)

            find(".button.project-vote-button").click
            expect(page).to have_css(".button.project-vote-button", exact_text: "Add", count: 1, visible: :visible)
          end
        end

        context "when full-text is enabled" do
          before do
            component.update(settings: { show_full_description_on_listing_page: true })
            sign_in user
            visit decidim_budgets.budget_voting_index_path(budget)
          end

          it "shows complete text for the project" do
            within("#project-#{project1.id}-item") do
              expect(page).to have_no_selector("button", text: translated(project1.title))
              expect(page).to have_no_selector("button", text: translated(project2.title))
              expect(page).to have_no_button("Read more")
              expect(page).to have_no_content(/.*\.{3}$/)
              expect(page).to have_content(strip_tags(translated(project1.description)))
            end
          end
        end

        it_behaves_like "filtering projects" do
          let!(:projects) { [project1, project2] }
          let(:current_component) { component }
          let(:voting_mode) { false }
        end

        context "when ordering by highest cost" do
          it_behaves_like "ordering projects by selected option", "Highest cost" do
            let(:first_project) { project2 }
            let(:last_project) { project1 }
          end
        end

        context "when ordering by lowest cost" do
          it_behaves_like "ordering projects by selected option", "Lowest cost" do
            let(:first_project) { project1 }
            let(:last_project) { project2 }
          end
        end

        describe "popups" do
          let!(:second_budget) { create(:budget, component:, total_budget: 100_000) }
          let!(:second_budgets_project) { create(:project, budget: second_budget, budget_amount: 75_000) }

          before do
            sign_in user
          end

          it "shows how to vote message by default" do
            visit decidim_budgets.budget_voting_index_path(budget)
            find(".button.project-vote-button", match: :first).click

            expect(page).to have_css("div#voting-help")
            within "div#voting-help" do
              expect(page).to have_content("Your vote has not been cast.")
              expect(page).to have_css("svg", count: 3)
              expect(page).to have_content("I understand how to vote")
            end
          end

          describe "thanks popup" do
            context "when default" do
              before do
                component.update!(settings: component_settings.merge(vote_success_content: { en: "<p>Some dummy text</p>" }))
                refresh
              end

              it "sets the text message with svg image by default" do
                vote_for_this(budget)
                expect(page).to have_css("div#thanks-message", count: 1)

                within "#thanks-message" do
                  expect(page).to have_content("Thank you for voting!")
                  expect(page).to have_css("svg", count: 1)
                  expect(page).to have_button("Continue")
                end
              end
            end

            context "when vote_success_content is nil" do
              before do
                vote_for_this(budget)
              end

              it "does not show popup" do
                expect(page).to have_current_path(decidim_budgets.budgets_path)
                expect(page).to have_no_css("div#thanks-message")
              end
            end

            context "when the current_workflow sets not to show thanks message image" do
              before do
                allow_any_instance_of(Decidim::Budgets::Workflows::All).to receive(:hide_image_in_popup?).and_return(true) # rubocop:disable RSpec/AnyInstance
                component.update!(settings: component_settings.merge(vote_success_content: { en: "<p>Some dummy text</p>" }))
              end

              it "sets the text message without svg image" do
                vote_for_this(budget)

                within "#thanks-message" do
                  expect(page).to have_content("Thank you for voting!")
                  expect(page).to have_no_css("svg")
                  expect(page).to have_button("Continue")
                end
              end
            end
          end

          describe "complete all votes popup" do
            context "when maximum_budgets_to_vote_on is set to zero" do
              let!(:order) { create(:order, user:, budget: second_budget) }

              before do
                order.projects << second_budgets_project
                order.checked_out_at = Time.current
                order.save
              end

              it "does not show the popup when vote_completed_content is nil" do
                vote_for_this(budget)

                expect(page).to have_content("Voted")
                expect(page).to have_no_css("div#vote-completed")
              end

              it "shows the popup with the text when the popup text is set" do
                component.update!(settings: component_settings.merge(vote_completed_content: { en: "<p>Some dummy text</p>" }))
                vote_for_this(budget)

                expect(page).to have_css("div#vote-completed", count: 1)
                within "div#vote-completed" do
                  expect(page).to have_content("You successfully completed your votes")
                  expect(page).to have_content("Some dummy text")
                end
              end
            end

            context "when maximum_budgets_to_vote_on is set" do
              before do
                component.update!(settings: component_settings.merge(vote_completed_content: { en: "<p>Some dummy text</p>" }, maximum_budgets_to_vote_on: 1))
              end

              it "shows the completed message" do
                vote_for_this(budget)
                expect(page).to have_css("div#vote-completed", count: 1)
                within "div#vote-completed" do
                  expect(page).to have_content("You successfully completed your votes")
                  expect(page).to have_content("Some dummy text")
                end
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
    end
  end

  private

  def vote_for_this(_budget)
    page.all(".button.project-vote-button").each { button & :click }
    find("[data-dialog-close='voting-help']", match: :first).click
    click_on "Vote budget"
    click_on "Confirm"
  end
end
