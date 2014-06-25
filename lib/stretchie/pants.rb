require 'active_support'
require 'elasticsearch/model'

module Stretchie
  module Pants
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model


      # Add the current model to the list of searchable models
      Stretchie::add_model self

      # Have the index name include the rails environment
      index_name "#{document_type}-#{ENV['RAILS_ENV']}"
    end


    # Update the document in the ElasticSearch index
    def update_in_index
      __elasticsearch__.index_document

      index_dependent_models.map(&:update_in_index)
    end


    # Delete the document from the ElasticSearch index
    def delete_from_index
      begin
        __elasticsearch__.delete_document
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        nil
      end

      index_dependent_models.map(&:update_in_index)
    end


    # Override to trigger dependent models to be re-indexed, should return
    # an array of models to run .update_in_index on.
    def index_dependent_models
      []
    end


    module ClassMethods

      # Search the index for a matching term
      def search(q, options={})
        fields = options.fetch(:fields, nil)

        query_string = {'query' => q}

        # If asked, limit the search to specific fields
        if !fields.nil?
          if !fields.kind_of? Array
            fields = [fields.to_s]
          end

          query_string['fields'] = fields
        end

        # Perform a default query search
        query = {
          'bool' => {
            'must' => [{'query_string' => query_string}]
          }
        }

        begin
          run_query query, options
        rescue Elasticsearch::Transport::Transport::Errors::BadRequest
          # This is probably because the query couldn't be parsed, clean it up
          # and try again
          query_string['query'] = sanitize(query_string['query'])

          run_query query, options
        end
      end


      # Search the specified field for a match
      def field_search(field, q, options={})
        # Search for a match based on prefix or a string match as a backup
        query = {
          'bool' => {
            'minimum_should_match' => 1,
            'should' => [
              {'prefix' => {field => q}},
              {'match'  => {field => q}}
            ]
          }
        }

        run_query query, options
      end


      # Execute a query hash in ElasticSearch
      def query_search(query, options={})
        run_query query, options
      end


      #
      # Private Methods
      #


      # Run a query hash in ElasticSearch
      def run_query(query, options={})
        query = prepare_query query, options

        # Run the query
        response = self.__elasticsearch__.search query

        Hashie::Mash.new({
          records: response.records,
          total_entries: response.results.total
        })
      end
      private :run_query


      # sanitize query string for Lucene. Useful if the original query raises an
      # exception due to invalid DSL parse.
      #
      # http://stackoverflow.com/questions/16205341/symbols-in-query-string-for-elasticsearch
      #
      # @return self [Stretchie::QueryString] the modified QueryString.
      def sanitize(q)
        # Escape special characters
        # http://lucene.apache.org/core/4_8_1/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#package_description#Escaping_Special_Characters
        escaped_characters = Regexp.escape('\\+-&|!(){}[]^~*?:\/')
        q = q.gsub(/([#{escaped_characters}])/, '\\\\\1')

        # AND, OR and NOT are used by lucene as logical operators. We need
        # to escape them
        ['AND', 'OR', 'NOT'].each do |word|
          escaped_word = word.split('').map {|char| "\\#{char}" }.join('')
          q = q.gsub(/\s*\b(#{word.upcase})\b\s*/, " #{escaped_word} ")
        end

        # Escape odd quotes
        if q.count('"') % 2 == 1
          q = q.gsub(/(.*)"(.*)/, '\1\"\2')
        end

        q
      end
      private :sanitize


      # Prepare a query hash for ElasticSearch
      def prepare_query(q_hash, options={})
        terms = options.fetch(:terms, {})
        limit = options.fetch(:limit, -1)
        skip  = options.fetch(:skip,  -1)
        order = options.fetch(:order, {})

        # Load the query but don't return any field data since we don't need it
        query = {
          'fields' => [],
          'query'  => q_hash
        }

        # If we have terms that must match (such as user_id) set them
        if terms.length > 0
          if q_hash.include?('term')
            q_hash['term'].merge! terms
          else
            if q_hash.include?('bool')
              if !q_hash['bool'].include?('must')
                q_hash['bool']['must'] = []
              end

              q_hash['bool']['must'] << {term: terms}
            else
              query['query'] = {
                'bool' => {
                  'must' => [q_hash]
                }
              }

              query['query']['bool']['must'] << {term: terms}
            end
          end
        end

        # Set the limit
        if limit > 0
          query['size'] = limit
        end

        # Set the number of records to skip
        if skip > 0
          query['from'] = skip
        end

        # Set the sort order, sorting by _score last
        if !query.include? 'sort'
          query['sort'] = []
        end

        order.map do |k, v|
          query['sort'] << {k => v}
        end

        if query['sort'].select { |x| x.keys.first == '_score' }.count == 0
          query['sort'] << {'_score' => 'desc'}
        end

        query
      end
      private :prepare_query
    end
  end
end
