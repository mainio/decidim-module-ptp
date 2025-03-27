$(() => {
  document.querySelectorAll(".project-item .card__list-content").forEach((link) => {
    link.addEventListener("click", (event) => {
      event.preventDefault();

      const projectItem = event.target.closest(".project-item");
      if (!projectItem) return;

      const projectId = projectItem.id.replace("project-", "").replace("-item", "");

      const modal = window.Decidim.currentDialogs[`project-modal-${projectId}`];
      if (modal) {
        modal.open();
      }
    });
  });
});
