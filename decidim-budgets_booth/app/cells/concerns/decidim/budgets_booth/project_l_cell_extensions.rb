# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the project card cell
    module ProjectLCellExtensions
      extend ActiveSupport::Concern

      included do
        delegate :current_workflow, :voting_open?, to: :controller

        def resource_text
          return decidim_sanitize(translated_attribute(model.description)) if show_full_description? && voting_open?

          decidim_sanitize_editor html_truncate(translated_attribute(model.description), length: 65, separator: "...")
        end

        def selected_budget
          return unless can_have_order? && resource_added?

          "hollow"
        end

        def voting_mode?
          options[:voting_mode]
        end

        private

        def show_full_description?
          current_workflow.budgets_component["settings"]["global"]["show_full_description_on_listing_page"] == true
        end
      end
    end
  end
end
