# frozen_string_literal: true

require "decidim/dev/common_rake"

def seed_db(path)
  Dir.chdir(path) do
    system("bundle exec rake db:seed")
  end
end

def install_modules(path)
  Dir.chdir(path) do
    system("bundle exec rake decidim_sms_twilio:install:migrations")
    system("bundle exec rake decidim_smsauth:install:migrations")
    system("bundle exec rake decidim_budgets_booth:install:migrations")
    system("bundle exec rake db:migrate")
  end
end

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  ENV["RAILS_ENV"] = "test"
  install_modules("spec/decidim_dummy_app")
end

desc "Generates a development app"
task :development_app do
  Bundler.with_original_env do
    generate_decidim_app(
      "development_app",
      "--app_name",
      "#{base_app_name}_development_app",
      "--path",
      "..",
      "--recreate_db",
      "--demo"
    )
  end

  install_modules("development_app")
  seed_db("development_app")
end

task :run_specs do
  modules = ["decidim-budgets_booth", "decidim-smsauth", "decidim-sms-twilio", "decidim-l10n"]

  modules.each do |module_name|
    Dir.chdir(module_name) do
      sh "bundle exec rspec spec"
      Dir.chdir("..")
    end
  end
end
