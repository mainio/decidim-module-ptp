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
        budget_description = style_description_text

        if voting_finished?
          budget_description.presence ||
            "<p class='inline-block text-xl text-left lg:text-center lg:w-4/6'>#{t("decidim.budgets.projects.pre_voting_budget_summary.voting_finished")}</p>"
        elsif voting_open?
          if vote_in_progress?
            [budget_description.presence, "<p class=\"inline-block text-xl text-left lg:text-center lg:w-4/6\">#{t(:finish_description, scope: i18n_scope)}</p>"].compact.join
          elsif current_order_checked_out?
            [
              budget_description.presence,
              "<p class=\"inline-block text-xl text-left lg:text-center lg:w-4/6\">
                #{t(".pre_vote.casted_description",
                    cancel_link: link_to(t(".cancel_order"), budget_order_path(return_to: "budget"),
                                         method: :delete,
                                         class: "cancel-order",
                                         data: { confirm: t(".are_you_sure") }))
                }
              </p>"
            ].compact.join
          else
            budget_description.presence || "<p class='inline-block text-xl text-left lg:text-center lg:w-4/6'>#{t(:start_description, scope: i18n_scope)}</p>"
          end
        else
          budget_description.presence || "<p class='inline-block text-xl text-left lg:text-center lg:w-4/6'>#{t(:pre_vote_start_description, scope: i18n_scope)}</p>"
        end
      end

      def style_description_text
        budget_description = translated_attribute(budget.description)
        return if strip_tags(budget_description).blank?

        doc = Nokogiri::HTML::DocumentFragment.parse(budget_description)
        doc.css("p").each { |p| p["class"] = "inline-block text-xl text-left lg:text-center lg:w-4/6" }
        doc.css("a").each { |a| a["class"] = "text-[--primary] font-semibold underline" }

        doc.to_html
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
