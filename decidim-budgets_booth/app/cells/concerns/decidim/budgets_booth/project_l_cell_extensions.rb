# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectLCellExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::VotingSupport

      included do
        delegate :selected?, to: :model

        def voting_mode?
          options[:voting_mode]
        end

        def show_votes?
          model.component.current_settings.show_votes?
        end
      end
    end
  end
end
