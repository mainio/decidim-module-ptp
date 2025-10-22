# frozen_string_literal: true

require "spec_helper"

module Decidim
  module BudgetsBooth
    module Import
      describe PaperOrdersCountCreator do
        subject { described_class.new(data) }

        let(:project) { create(:project, component: create(:budgets_component)) }

        context "when data is valid" do
          let(:data) do
            {
              project_id: project.id.to_s,
              project_title: project.title,
              number_of_votes: "13"
            }
          end

          it "updates the project's paper orders count" do
            expect { subject.produce }.to change { project.reload.paper_orders_count }.to(13)
          end
        end

        context "when id is invalid" do
          let(:data) do
            {
              project_id: (project.id - 1).to_s,
              project_title: project.title,
              number_of_votes: "11"
            }
          end

          it "gives an ActiveRecord::RecordNotFound -error" do
            expect { subject.produce }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
