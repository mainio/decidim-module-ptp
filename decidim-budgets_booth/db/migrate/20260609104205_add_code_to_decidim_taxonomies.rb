# frozen_string_literal: true

class AddCodeToDecidimTaxonomies < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_taxonomies, :code, :string
    add_index :decidim_taxonomies, [:decidim_organization_id, :code], unique: true
  end
end
