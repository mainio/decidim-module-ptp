# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectLCellExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::VotingSupport

      included do
        def voting_mode?
          options[:voting_mode]
        end
      end
    end
  end
end
