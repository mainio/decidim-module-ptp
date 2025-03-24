# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/ptp/version"

DECIDIM_VERSION = Decidim::Ptp.decidim_version

gem "decidim", DECIDIM_VERSION
gem "decidim-ptp", path: "."

gem "bootsnap", "~> 1.4"

# This is a temporary fix for: https://github.com/rails/rails/issues/54263
# Without this downgrade Activesupport will give error for missing Logger
gem "concurrent-ruby", "1.3.4"

gem "puma", ">= 6.4.2"

gem "faker", "~> 3.2.2"

# This locks nokogiri to a version < 1.17 so it doesn't cause issues
gem "nokogiri", "1.16.8"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
  gem "decidim-initiatives", DECIDIM_VERSION

  gem "brakeman", "~> 5.2"
  # Ruby 3.0 -> (Decidim 0.27.x ->)
  # gem "net-imap", "~> 0.2.3"
  # gem "net-pop", "~> 0.1.1"
  # gem "net-smtp", "~> 0.3.1"
  gem "parallel_tests", "~> 4.2"

  # rubocop & rubocop-rspec are set to the following versions because of a change where FactoryBot/CreateList
  # must be a boolean instead of contextual. These version locks can be removed when this problem is handled
  # through decidim-dev.
  gem "rubocop", "~>1.28"
  gem "rubocop-faker"
  gem "rubocop-rspec", "2.20"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.8"
  gem "spring", "~> 4.1.3"
  gem "spring-watcher-listen", "~> 2.1"
  gem "web-console", "~> 4.2"
end
