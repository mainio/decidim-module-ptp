# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectVotedHintCellExtensions
      extend ActiveSupport::Concern

      included do
        def show
          return voted?(model) unless controller.respond_to?(:voted_for?)
          return unless voted_for?(model)

          content_tag :span, safe_join(hint), class: css_class
        end

        def voted?(model)
          return false unless current_user && model.orders.pluck(:decidim_user_id).include?(current_user.id)

          content_tag :span, safe_join(hint), class: css_class
        end

        def css_class
          css = []
          css << options[:class] if options[:class]
          css << "text-sm" unless options[:class]&.include?("text-m")
          css.join(" ")
        end
      end
    end
  end
end
