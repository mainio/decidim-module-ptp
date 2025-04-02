# frozen_string_literal: true

shared_examples "cancel voting" do
  before do
    visit current_path
  end

  it "redirects the user to root" do
    find(".voting-rules [data-dialog-open='cancel-voting']", match: :first).click
    within "#cancel-voting" do
      expect(page).to have_content "Are you sure you don't want to cast your vote?"
      expect(page).to have_css("button.button.expanded", text: "Continue voting")
      expect(page).to have_css("a.button.hollow.expanded", text: "I don't want to vote right now")
      click_on "Continue voting"
    end
    find(".voting-rules [data-dialog-open='cancel-voting']", match: :first).click
    within "#cancel-voting" do
      click_on "I don't want to vote right now"
    end
    expect(page).to have_current_path("/")
  end

  context "when vote_cancel_url is set to a specific location" do
    before do
      component.update!(settings: component_settings.merge(workflow: "zip_code", vote_cancel_url: decidim_budgets.budgets_path))
      visit current_path
    end

    it "redirects to the correct location" do
      find(".voting-rules [data-dialog-open='cancel-voting']", match: :first).click
      within "#cancel-voting" do
        expect(page).to have_content "Are you sure you don't want to cast your vote?"
        expect(page).to have_css("button.button.expanded", text: "Continue voting")
        expect(page).to have_css("a.button.hollow.expanded", text: "I don't want to vote right now")
        click_on "Continue voting"
      end
      find(".voting-rules [data-dialog-open='cancel-voting']", match: :first).click
      within "#cancel-voting" do
        click_on "I don't want to vote right now"
      end
      expect(page).to have_current_path(decidim_budgets.budgets_path)
    end
  end
end
