$(function() {
  const initVoteCompleteElement = () => {
    const modalContent = $("#vote-completed-snippet").html();

    $("body").append(modalContent);

    let dialog = new window.Decidim.Dialogs("#vote-completed")
    window.Decidim.currentDialogs["vote-completed"] = dialog;

    window.Decidim.currentDialogs["vote-completed"].open();
  }

  initVoteCompleteElement();
});
