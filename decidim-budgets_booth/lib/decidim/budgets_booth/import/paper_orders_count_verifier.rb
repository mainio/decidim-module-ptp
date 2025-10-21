# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module Import
      class PaperOrdersCountVerifier < Decidim::Admin::Import::Verifier
        protected

        def required_headers
          %w(project_id project_title number_of_votes)
        end

        # Check if prepared resource is valid
        #
        # record - Decidim::Budgets::Project
        #
        # Returns true if record is valid
        def valid_record?(record)
          return false if record.nil?
          return false if record.errors.any?

          record.valid?
        end
      end
    end
  end
end
