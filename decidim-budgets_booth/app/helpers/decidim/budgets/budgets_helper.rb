# frozen_string_literal: true

module Decidim
  module Budgets
    module BudgetsHelper
      include ::Decidim::BudgetsBooth::VotingSupport

      def vote_success_content
        translated_attribute(component_settings.try(:vote_success_content))&.html_safe
      end
    end
  end
end
