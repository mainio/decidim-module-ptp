# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class TaxonomyManager
      attr_reader :component, :top_taxonomy

      class << self
        # This method allows storing the taxonomies mappings locally so that they do
        # not have to be re-fetched for the multiple instances of the
        # TaxonomyManager class.
        def taxonomies_mapping_for(taxonomies)
          Array(taxonomies).each_with_object({}) do |taxonomy, hash|
            hash[taxonomy.id] = taxonomies_mapping_cache[taxonomy.id] ||= Rails.cache.fetch(
              cache_key(taxonomy.cache_key_with_version),
              expires_in: 1.hour
            ) { generate_taxonomies_mapping_for(taxonomy) }
          end
        end

        # Allow clearing the cache, useful for the specs.
        def clear_cache!
          taxonomies_mapping_cache.keys.each do |id|
            taxonomy = Decidim::Taxonomy.find(id)

            Rails.cache.delete(cache_key(taxonomy.cache_key_with_version))
          rescue ActiveRecord::RecordNotFound
            # If the record was not found, cache key cannot be regenerated, so
            # deleting the old cache record can be omitted.
          end
          @taxonomies_mapping_cache = {}
        end

        private

        def cache_key_prefix
          "decidim/budgets_booth/taxonomies_mapping"
        end

        def cache_key(key)
          "#{cache_key_prefix}/#{key}"
        end

        # Stores the local cache of the taxonomies mappings.
        def taxonomies_mapping_cache
          @taxonomies_mapping_cache ||= {}
        end

        # Generates the taxonomies mapping for the given top-level taxonomy.
        def generate_taxonomies_mapping_for(taxonomy)
          locale = taxonomy.organization.default_locale
          table = Decidim::Taxonomy.table_name
          connection = ActiveRecord::Base.connection
          columns = "id, parent_id, code, name->>#{connection.quote(locale)} AS name"
          topquery = "SELECT %columns% FROM #{table} WHERE parent_id = #{connection.quote(taxonomy.id)}"
          queries = []

          # Maximum of 3 levels below the top taxonomy:
          #   Boroughs -> Neighborhoods -> Postal codes
          #
          # The postal codes are defined at the deepest level regardless of the
          # amount of levels.
          subquery = topquery
          3.times do |i|
            queries << subquery.sub("%columns%", "#{columns}, #{i} AS depth")
            subquery = "SELECT %columns% FROM #{table} WHERE parent_id IN (#{subquery.sub("%columns%", "id")})"
          end

          # Query all the levels and store the postal code mapping. Note that
          # the order by depth is important for the further processing. The
          # lowest depth needs to be processed first.
          result = connection.select_all("#{queries.join(" UNION ALL ")} ORDER BY depth, name").to_a

          zip_codes_hash(taxonomy, result)
        end

        # Converts the multi-level query results into a flat hash which has the
        # taxonomy IDs as keys and their related ZIP codes as values. This approach
        # allows quickly fetching the ZIP codes for each taxonomy.
        def zip_codes_hash(parent_taxonomy, result)
          max_depth = result.pluck("depth").max
          parents = { parent_taxonomy.id => [] }

          {}.tap do |mapping|
            result.each do |item|
              if item["depth"] == max_depth
                # Postal code
                mapping[item["parent_id"]] ||= []
                mapping[item["parent_id"]] << item["name"]

                each_item(parents, item["parent_id"]) do |parent_id|
                  mapping[parent_id] ||= []
                  mapping[parent_id] << item["name"]
                end
              elsif item["depth"].positive?
                parents[item["id"]] ||= []
                parents[item["id"]] << item["parent_id"] unless parents[item["id"]].include?(item["parent_id"])

                each_item(parents, item["parent_id"]) do |parent_id|
                  parents[item["id"]] << parent_id unless parents[item["id"]].include?(parent_id)
                end
              end
            end
          end
        end

        # This is a helper method to reduce the cyclomatic complexity of the
        # `zip_codes_hash` method.
        def each_item(parents, id)
          return unless parents[id]

          parents[id].each { |parent_id| yield parent_id }
        end
      end

      def initialize(component)
        @component = component
        @top_taxonomy = component.available_root_taxonomies
      end

      def zip_codes_for(resource)
        return [] unless top_taxonomy

        taxonomies = taxonomies_for(resource)
        return [] if taxonomies.blank?

        taxonomies.flat_map do |taxonomy|
          if top_taxonomy.include?(taxonomy)
            taxonomies_mapping.values.flat_map(&:values).flatten
          else
            taxonomies_mapping.values.flat_map { |map| map[taxonomy.id] }.compact
          end
        end.uniq
      end

      def user_zip_code(user)
        return nil if user.blank?

        user_data_for(user)["zip_code"]
      end

      private

      # Loads the metadata for a specific user from the user data records. If
      # the cache clear method has been called after the user data was loaded
      # (e.g. the data was deleted or updated at the same process), this will
      # reload the data accordingly.
      def user_data_for(user)
        user_data = user.budgets_user_data.find_by(component:)
        user_data&.metadata || {}
      end

      def taxonomies_for(resource)
        return [resource] if resource.is_a?(Decidim::Taxonomy)

        resource.taxonomies.select { |t| top_taxonomy.include?(t) || top_taxonomy.include?(t.parent) }
      end

      def taxonomies_mapping
        self.class.taxonomies_mapping_for(top_taxonomy)
      end
    end
  end
end
