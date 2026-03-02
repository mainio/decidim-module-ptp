# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::ProjectVotedHintCellExtensions do
  let(:klass) do
    Class.new do
      include Decidim::BudgetsBooth::ProjectVotedHintCellExtensions
    end
  end

  before do
    allow_any_instance_of(klass).to receive(:options).and_return(options) # rubocop:disable RSpec/AnyInstance
  end

  describe "#css_class" do
    context "when options[:class] is not present" do
      let(:options) do
        { class: nil }
      end
    end

    context "when options[:class] is present" do
      let(:options) do
        { class: "my-class" }
      end
    end

    context "when options[:class] includes 'text-m'" do
      let(:options) do
        { class: "text-m" }
      end

      it "does not add 'text-sm' to the returned string" do
        expect(klass.new.css_class).not_to include("text-sm")
      end
    end
  end
end
