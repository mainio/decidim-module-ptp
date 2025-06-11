$(() => {
  const showProjectsButton = document.getElementById("show-projects");
  const projectsCount = document.getElementById("projects-count");

  showProjectsButton.addEventListener("click", (ev) => {
    ev.preventDefault();

    projectsCount.scrollIntoView({
      behavior: "smooth",
      block: "start"
    });
  })
})
