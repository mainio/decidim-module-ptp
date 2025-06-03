$(() => {
  const checkProgressPosition = () => {
    let progressFix = document.querySelector("[data-progressbox-fixed]"),
        progressRef = document.querySelector("[data-progress-reference]")

    if (!progressRef || !progressFix) {
      return;
    }

    let progressPosition = progressRef.getBoundingClientRect().top + 145;
    if (progressPosition > 0) {
      progressFix.classList.add("hidden");
    } else {
      progressFix.classList.remove("hidden");
    }
  }

  window.addEventListener("scroll", checkProgressPosition);

  window.DecidimBudgets = window.DecidimBudgets || {};
  window.DecidimBudgets.checkProgressPosition = checkProgressPosition;
});
