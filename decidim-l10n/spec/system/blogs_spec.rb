# frozen_string_literal: true

require "spec_helper"

describe "ExploreBlogs", versioning: true do
  include_context "with a component"
  let(:manifest_name) { "blogs" }

  let(:first_post_date) { Time.zone.local(2017, 1, 13, 8, 0, 0) }
  let(:second_post_date) { Time.zone.local(2017, 12, 20, 15, 0, 0) }
  let!(:first_post) { create(:post, component:, created_at: first_post_date, published_at: first_post_date) }
  let!(:second_post) { create(:post, component:, created_at: second_post_date, published_at: second_post_date) }

  let!(:first_comment) { create(:comment, commentable: first_post) }
  let!(:second_comment) { create(:comment, commentable: second_post) }

  describe "index" do
    it "shows all posts for the given process" do
      visit_component

      within "#blogs__post_#{first_post.id}" do
        within(".card__list-metadata") do
          expect(page).to have_content("Jan 13 2017")
        end
      end

      within "#blogs__post_#{second_post.id}" do
        within(".card__list-metadata") do
          expect(page).to have_content("Dec 20 2017")
        end
      end
    end
  end
end
