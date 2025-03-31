// Overwrite this file to keep JS order working instead of overwriting "projects/index.html.erb" like in version 0.27.

// If - instead of using the core's projects -file like this and creating a new one and adding the pack_tag to "projects/index.html.erb"
// like what was done in 0.27 (entrypoint - decidim_budgets_booth_voting) the filtering feature doesn't work for the budgets view ("projects/index.html.erb")
// since it breaks the javascript

import "src/decidim/budgets_booth/exit_handler"
import "src/decidim/budgets_booth/popup_selected_project"

const initializeProjects = () => {
  const $voteButtons = $(".customized-budget");
  const $budgetSummaryTotal = $(".budget-summary__progressbar-marks_right");
  const selectBudgetSummaryTotal = $budgetSummaryTotal.data("totalAllocation");
  const $budgetSummary = $(".budget-summary__progressbox");
  const totalAllocation = parseInt(selectBudgetSummaryTotal, 10);
  const additionSelectorButtons = document.querySelectorAll(".budget__list--header .button__pill")

  const cancelEvent = (event) => {
    event.stopPropagation();
    event.preventDefault();
  };
  $voteButtons.on("click", (event) => {
    const currentAllocation = parseInt($budgetSummary.attr("data-current-allocation"), 10);
    const $currentTarget = $(event.currentTarget);
    const projectAllocation = parseInt($currentTarget.attr("data-allocation"), 10);

    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if (($currentTarget.attr("data-add") === "true") && ((currentAllocation + projectAllocation) > totalAllocation)) {
      Object.keys(window.Decidim.currentDialogs).forEach(dialogKey => {
        if (dialogKey.startsWith("project-modal-")) {
          let dialog = window.Decidim.currentDialogs[dialogKey];
          if (dialog.isOpen) {
            dialog.close();
          }
        }
      })
      window.Decidim.currentDialogs["budget-excess"].toggle()
      cancelEvent(event);
    }
  });

  additionSelectorButtons.forEach(function(button) {
    button.addEventListener("click", function(event) {
      additionSelectorButtons.forEach(function(element) {
        element.classList.remove("button__pill--active")
      })
      event.currentTarget.classList.add("button__pill--active")
    })
  });
};


$(() => {
  initializeProjects();
});
