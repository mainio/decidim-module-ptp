$(() => {
  const showProjectsButton = document.getElementById("show-projects");
  const projectsCount = document.getElementById("projects-count");
  const statusModal = window.Decidim.currentDialogs["status-summary"];

  if (statusModal) {
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
