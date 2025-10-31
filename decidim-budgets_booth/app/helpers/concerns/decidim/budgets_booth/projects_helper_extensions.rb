# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the projects helper
    module ProjectsHelperExtensions
      include VotingSupport

      delegate :progress?, :budgets, :user_zip_code, to: :current_workflow

      def voting_mode?
        false
      end

      def i18n_scope
        "decidim.budgets.projects.pre_voting_budget_summary.pre_vote"
      end

      def vote_text
        key = if current_workflow.vote_allowed?(budget) && progress?(budget)
                :finish_voting
              else
                :start_voting
              end

        t(key, scope: i18n_scope)
      end

      def description_text
        return strip_tags(translated_attribute(budget.description)) if strip_tags(translated_attribute(budget.description)).present? && !vote_in_progress?

        key = if vote_in_progress?
                :finish_description
              else
                :start_description
              end

        t(key, scope: i18n_scope)
      end

      def vote_in_progress?
        current_workflow.vote_allowed?(budget) && progress?(budget)
      end

      def budgets_count
        Decidim::Budgets::Budget.where(component: current_component).count
      end

      def current_phase
        process = Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses
                  .new(current_organization).query.find_by(slug: params[:participatory_process_slug])
        process&.active_step&.title
      end

      def voting_booth_forced?
        current_workflow.try(:voting_booth_forced?)
      end

      def voting_terms
        translated_attribute(component_settings.try(:voting_terms)).presence
      end
    end
  end
end
