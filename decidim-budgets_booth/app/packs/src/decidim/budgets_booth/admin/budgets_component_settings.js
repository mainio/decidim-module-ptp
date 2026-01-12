$(() => {
  const language = document.documentElement.getAttribute("lang") || "en";

  const landingLabels = document.querySelectorAll(
    'label[for="component_settings_landing_page_content"], ' +
    'label[for^="component_step_settings_"][for$="_landing_page_content"]'
  );

  const termsLabel = document.querySelector(
    'label[for="component_settings_voting_terms"]'
  )

  const helpTranslations = {
    en: {
      landing_page_help_text: "This setting only applies when there are multiple budgets.",
      terms_help_text: 'This setting only applies when "Vote based on ZIP code" -workflow is selected.'
    },
    fi: {
      landing_page_help_text: "Tämä asetus vaatii useamman budjetin toimiakseen.",
      terms_help_text: 'Tämä asetus vaatii "Äänestä postinumeron perusteella" -asetuksen toimiakseen.'
    }
  }

  if (!landingLabels || !termsLabel) { return; }

  const landingHelpText =
    helpTranslations[language]?.landing_page_help_text ||
    helpTranslations["en"]?.landing_page_help_text;

  const termsHelpText =
    helpTranslations[language]?.terms_help_text ||
    helpTranslations["en"]?.terms_help_text;

  landingLabels.forEach(label => {
    const labelRow = label.closest("div.label--tabs");

    if (labelRow.nextElementSibling?.classList.contains("help-text")) {
      return;
    }

    const helpLanding = document.createElement("p");
    helpLanding.className = "help-text";
    helpLanding.textContent = landingHelpText;

    labelRow.insertAdjacentElement("afterend", helpLanding);
  })

  const termsRow = termsLabel.closest("div.label--tabs");

  if (termsRow.nextElementSibling?.classList.contains("help-text")) {
    return;
  }

  const helpTerms = document.createElement("p");
  helpTerms.className = "help-text";
  helpTerms.textContent = termsHelpText;

  termsRow.insertAdjacentElement("afterend", helpTerms);
})
