# frozen_string_literal: true

require "twilio-ruby"

require "decidim/sms/twilio/engine"

module Decidim
  module Sms
    # This namespace holds the logic for Twilio SMS integration.
    module Twilio
      autoload :TokenGenerator, "decidim/sms/twilio/token_generator"
      autoload :Gateway, "decidim/sms/twilio/gateway"
      autoload :ContentSecurityPolicyExtensions, "decidim/sms/twilio/content_security_policy_extensions"
    end
  end
end
