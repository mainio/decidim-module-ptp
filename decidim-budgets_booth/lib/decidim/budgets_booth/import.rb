# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module Import
      autoload :PaperOrdersCountCreator, "decidim/budgets_booth/import/paper_orders_count_creator"
      autoload :PaperOrdersCountVerifier, "decidim/budgets_booth/import/paper_orders_count_verifier"
    end
  end
end
