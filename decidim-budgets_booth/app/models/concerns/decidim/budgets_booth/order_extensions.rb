# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module OrderExtensions
      extend ActiveSupport::Concern

      included do
        def can_checkout?
          if projects_rule?
            total_projects >= minimum_projects && total_projects <= maximum_projects && total_projects.positive?
          elsif minimum_projects_rule?
            total_projects >= minimum_projects
          else
            total_budget.to_f >= minimum_budget && total_budget.to_f.positive?
          end
        end
      end
    end
  end
end
