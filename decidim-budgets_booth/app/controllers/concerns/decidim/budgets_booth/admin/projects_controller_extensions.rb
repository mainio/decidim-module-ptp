# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module Admin
      module ProjectsControllerExtensions
        extend ActiveSupport::Concern

        included do
          private

          def finished_orders
            orders.finished.count + projects.sum(&:paper_orders_count)
          end
        end
      end
    end
  end
end
