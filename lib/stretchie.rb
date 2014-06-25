require 'set'

# ElasticSearch
# require 'elasticsearch'

# Stretchie Core
require 'stretchie/version'

# Lets put our Stretchie::Pants on
require 'stretchie/pants'


# Defaults
module Stretchie

  # Set containing all registered models
  @@models = Set.new


  # Add a model to the set
  def self.add_model model
    @@models << model
  end


  # Returns a set containing all registered models
  def self.models
    @@models
  end


  # Create or update all indices across all registered models
  def self.update_indices(*args)
    result = true

    if args.length > 0
      args = args.map { |m| m.to_s.singularize.capitalize.constantize }
      _models = models.select { |m| args.include? m }
    else
      _models = models
    end

    _models.map do |m|
      create = m.__elasticsearch__.create_index!
      if !create.nil?
        result &= create['acknowledged']
      else
        m.mappings.to_hash.map do |map, body|
          client = m.__elasticsearch__.client
          update = client.indices.put_mapping index: m.index_name, type: map,
            body: {map => body}

          if update.kind_of?(Hash)
            result &= update['acknowledged']
          end
        end
      end
    end

    result
  end


  # Refresh all indices across all registered models
  def self.refresh_indices(*args)
    result = true

    if args.length > 0
      args = args.map { |m| m.to_s.singularize.capitalize.constantize }
      _models = models.select { |m| args.include? m }
    else
      _models = models
    end

    _models.map do |m|
      refresh = m.__elasticsearch__.refresh_index!
      if refresh.kind_of?(Hash) && refresh.include?('_shards')
        result &= refresh['_shards']['failed'] == 0
      end
    end

    result
  end


  # Delete all indices across all registered models
  def self.delete_indices(*args)
    result = true

    if args.length > 0
      args = args.map { |m| m.to_s.singularize.capitalize.constantize }
      _models = models.select { |m| args.include? m }
    else
      _models = models
    end

    _models.map do |m|
      delete = m.__elasticsearch__.delete_index!

      if !delete.nil?
        result &= delete['acknowledged']
      end
    end

    result
  end
end
