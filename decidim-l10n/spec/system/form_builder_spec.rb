# frozen_string_literal: true

require "spec_helper"

describe "FormBuilder" do
  subject { described_class.new(template, options) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      include ActionView::Helpers::FormHelper

      def protect_against_forgery?
        false
      end

      def snippets
        @snippets ||= Decidim::Snippets.new
      end
    end
  end
  let(:record_class) do
    Class.new(Decidim::Form) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "dummy")
      end

      attribute :start_time, DateTime
    end
  end
  let(:organization) { create(:organization) }
  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

  let(:html_document) do
    form_object = record_class.new(start_time: Time.zone.local(2017, 2, 15, 15, 35, 0))
    inner_html = template.instance_eval do
      form_for(form_object, builder: Decidim::FormBuilder, url: "/") do |form|
        form.datetime_field(:start_time)
      end
    end
    template.instance_eval do
      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Autocomplete multiselect Test</title>
          #{stylesheet_pack_tag "decidim_admin"}
          #{javascript_pack_tag "decidim_admin"}
          #{snippets.display(:head)}
        </head>
        <body>
          <h1>Hello world</h1>
          #{inner_html}
        </body>
        </html>
      HTML
    end
  end

  before do
    allow(template).to receive(:current_organization).and_return(organization)

    # Create a temporary route to display the generated HTML in a correct site
    # context.
    final_html = html_document
    Rails.application.routes.draw do
      get "form_builder", to: ->(_) { [200, {}, [final_html]] }
      get "/favicon.ico", to: ->(_) { [204, {}, []] }
    end

    switch_to_host(organization.host)
    visit "/form_builder"
  end

  after do
    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  it "renders the date/time selector" do
    expect(page).to have_content("Start time")
    expect(page).to have_css("input[value='2017-02-15T15:35:00']")
  end
end
