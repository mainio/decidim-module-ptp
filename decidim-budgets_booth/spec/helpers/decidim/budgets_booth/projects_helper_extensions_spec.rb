# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::ProjectsHelperExtensions do
  describe "#current_phase" do
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let!(:first_step) do
      create(:participatory_process_step,
             active: true,
             end_date: Time.zone.now.to_date,
             participatory_process:)
    end
    let!(:second_step) do
      create(:participatory_process_step,
             active: false,
             end_date: 1.month.from_now.to_date,
             participatory_process:)
    end

    before do
      allow(helper).to receive(:current_organization).and_return(organization)
      allow(helper).to receive(:params).and_return({ participatory_process_slug: participatory_process.slug })
    end

    it "returns the title of the active step in the current participatory process" do
      expect(helper.current_phase).to eq(first_step.title)
    end

    context "when there is no active step in the current participatory process" do
      before do
        first_step.update(active: false)
      end

      it "returns nil" do
        expect(helper.current_phase).to be_nil
      end
    end

    context "when the current participatory process cannot be found" do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Decidim::ParticipatoryProcessStep).to receive(:title).and_return(nil)
        # rubocop:enable RSpec/AnyInstance
      end

      it "returns nil" do
        expect(helper.current_phase).to be_nil
      end
    end
  end
end
