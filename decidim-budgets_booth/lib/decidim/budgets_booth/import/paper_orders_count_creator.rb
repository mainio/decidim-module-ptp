# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module Import
      class PaperOrdersCountCreator < Decidim::Admin::Import::Creator
        def self.resource_klass
          Decidim::Budgets::Project
        end

        def self.verifier_klass
          Decidim::BudgetsBooth::Import::PaperOrdersCountVerifier
        end

        def produce
          resource
        end

        private

        def resource
          @resource ||= begin
            project = Decidim::Budgets::Project.find(id)
            project.update!(
              paper_orders_count: votes
            )
            project
          end
        end

        def id
          data[:project_id].to_i
        end

        def votes
          data[:number_of_votes].to_i
        end
      end
    end
  end
end
