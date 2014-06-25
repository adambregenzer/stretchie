require 'active_record'
require 'logger'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Base.logger = Logger.new STDOUT
ActiveRecord::Base.logger.level = Logger::WARN
ActiveSupport::LogSubscriber.colorize_logging = false


ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users do |t|
    t.string  :name
    t.string  :email
    t.integer :misc_id
  end
end


module Search
  module User
    extend ActiveSupport::Concern
    include Stretchie::Pants

    included do
      settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
          indexes :name, analyzer: 'whitespace', index_options: 'offsets'
          indexes :email
          indexes :misc_id
          indexes :sortable_name
        end
      end
    end


    def as_indexed_json(options={})
      json = as_json(only: [:name, :email, :misc_id])
      json['sortable_name'] = self.name.downcase
      json
    end
  end
end


class User < ActiveRecord::Base
  include Search::User
  attr_accessor :name, :email, :misc_id
end
