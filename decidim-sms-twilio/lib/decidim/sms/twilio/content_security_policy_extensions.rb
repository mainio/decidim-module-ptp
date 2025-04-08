# frozen_string_literal: true

module Decidim
  module Sms
    module Twilio
      module ContentSecurityPolicyExtensions
        extend ActiveSupport::Concern

        included do
          policies = remove_const("SUPPORTED_POLICIES")
          const_set("SUPPORTED_POLICIES", (policies + %w(sid status)).freeze)
        end
      end
    end
  end
end
