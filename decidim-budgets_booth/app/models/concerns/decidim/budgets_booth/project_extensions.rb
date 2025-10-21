# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectExtensions
      extend ActiveSupport::Concern

      included do
        scope :with_votes, lambda {
          scope = klass.joins(
            <<~SQLJOIN.squish
              LEFT OUTER JOIN decidim_budgets_line_items
                ON decidim_budgets_line_items.decidim_project_id = decidim_budgets_projects.id
            SQLJOIN
          ).joins(
            <<~SQLJOIN.squish
              LEFT OUTER JOIN decidim_budgets_orders
                ON decidim_budgets_orders.id = decidim_budgets_line_items.decidim_order_id
                AND decidim_budgets_orders.checked_out_at IS NOT NULL
            SQLJOIN
          ).select(
            "decidim_budgets_projects.id",
            "COUNT(decidim_budgets_orders.id) + decidim_budgets_projects.paper_orders_count AS votes_count",
            "CASE #{Arel.sql locale_case("decidim_budgets_projects.title")} END AS localized_title"
          ).group("decidim_budgets_projects.id")

          joins(
            Arel.sql(
              <<~SQLJOIN.squish
                LEFT OUTER JOIN (#{scope.to_sql}) AS decidim_budgets_projects_with_votes
                  ON decidim_budgets_projects_with_votes.id = decidim_budgets_projects.id
              SQLJOIN
            )
          )
        }

        def confirmed_orders_count
          orders.finished.count + paper_orders_count
        end
      end
    end
  end
end
