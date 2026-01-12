# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module Admin
      module ComponentsControllerExtensions
        extend ActiveSupport::Concern

        included do
          def edit
            @component = query_scope.find(params[:id])
            enforce_permission_to :update, :component, component: @component

            budgets_component_javascript

            @form = form(@component.form_class).from_model(@component)
          end

          private

          def budgets_component_javascript
            snippets.add(:foot, view_context.javascript_pack_tag("decidim_budgets_booth_budgets_component_settings"))
          end
        end
      end
    end
  end
end
