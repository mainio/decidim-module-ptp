# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module CreateBudgetExtensions
      extend ActiveSupport::Concern

      included do
        def attributes
          super.merge(attachment_attributes(:main_image))
        end
      end
    end
  end
end
