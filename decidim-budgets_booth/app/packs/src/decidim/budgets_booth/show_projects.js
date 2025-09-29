$(() => {
  const showProjectsButton = document.getElementById("show-projects");
  const projectCount = document.getElementById("project-count");
  const statusModal = window.Decidim.currentDialogs["status-summary"];
  const statusTrigger = document.getElementById("trigger-status");

  if (statusModal && statusTrigger) {
    statusModal.open();
  }

  if (showProjectsButton) {
    showProjectsButton.addEventListener("click", (ev) => {
      ev.preventDefault();

      projectCount.scrollIntoView({
        behavior: "smooth",
        block: "start"
      });
    })
  }
})
