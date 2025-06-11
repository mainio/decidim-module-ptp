import "src/decidim/budgets_booth/exit_handler"
import "src/decidim/budgets_booth/popup_selected_project"

const initializeProjects = () => {
  const $voteButtons = $(".customized-budget");
  const $budgetSummaryTotal = $(".budget-summary__total");
  const selectBudgetSummaryTotal = $budgetSummaryTotal.data("totalAllocation");
  const $budgetSummary = $(".budget-summary__progressbox");
  const totalAllocation = parseInt(selectBudgetSummaryTotal, 10);

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
};

export default initializeProjects;
