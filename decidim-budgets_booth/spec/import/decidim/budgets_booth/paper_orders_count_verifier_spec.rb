# frozen_string_literal: true

require "spec_helper"

module Decidim
  module BudgetsBooth
    module Import
      describe PaperOrdersCountVerifier do
        subject { described_class.new(**data) }

        let(:data) do
          {
            headers: [],
            data: [],
            reader: nil
          }
        end

        let(:project) { create(:project, component: create(:budgets_component)) }

        describe "#valid_record?" do
          it "returns true for a valid project" do
            expect(subject.send(:valid_record?, project)).to be(true)
          end

          it "returns false for a nil record" do
            expect(subject.send(:valid_record?, nil)).to be(false)
          end

          it "returns false if record has errors" do
            project.errors.add(:title, "This is an error")
            expect(subject.send(:valid_record?, project)).to be(false)
          end
        end
      end
    end
  end
end
