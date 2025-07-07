$(() => {
  const showProjectsButton = document.getElementById("show-projects");
  const projectsCount = document.getElementById("projects-count");
  const statusModal = window.Decidim.currentDialogs["status-summary"];
  const statusTrigger = document.getElementById("trigger-status");

  if (statusModal && statusTrigger) {
    statusModal.open();
  }

  if (showProjectsButton) {
    showProjectsButton.addEventListener("click", (ev) => {
      ev.preventDefault();

      projectsCount.scrollIntoView({
        behavior: "smooth",
        block: "start"
      });
    })
  }
})
