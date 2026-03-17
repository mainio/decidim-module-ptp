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

        def show_votes?
          model.component.current_settings.show_votes?
        end

        def selected?
          model.selected?
        end
      end
    end
  end
end
