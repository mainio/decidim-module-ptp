$(() => {
  const progressElement = document.querySelector(".vote-progress-container");
  const spacer = document.querySelector(".progress-spacer");
  const summary = document.querySelector(".budget-summary__total");
  const selectedProjects = document.getElementById("order-selected-projects");
  const budgetProgress = document.querySelector(".budget-progress");
  const progressMeter = document.querySelector(".progress-meter");
  const progressReady = document.querySelector(".progress-ready-button");
  let sticky = false;

  const checkProgressPosition = () => {
    const top = progressElement.getBoundingClientRect().top;
    const spacerTop = spacer.getBoundingClientRect().top;

    if (top <= 0 && !sticky) {
      const height = progressElement.offsetHeight;

      progressElement.classList.add("w-full", "fixed", "top-0", "progress-background");
      selectedProjects.classList.remove("my-4");
      selectedProjects.classList.add("my-2");
      summary.classList.add("hidden");
      spacer.style.height = `${height}px`;
      sticky = true;
    } else if (spacerTop > 0 && sticky) {
      progressElement.classList.remove("w-full", "fixed", "top-0", "progress-background");
      selectedProjects.classList.add("my-4")
      selectedProjects.classList.remove("my-2");
      summary.classList.remove("hidden");
      spacer.style.height = "0px";
      sticky = false;
    }
  }

  if (progressElement) {
    window.addEventListener("scroll", checkProgressPosition);

    window.DecidimBudgets = window.DecidimBudgets || {};
    window.DecidimBudgets.checkProgressPosition = checkProgressPosition;
  }
});
