$(() => {
  const $modal = $("#thanks-message");

  if (Boolean($modal) && $modal.attr("data-session") === "true") {
    window.Decidim.currentDialogs["thanks-message"].open();
  }
});
