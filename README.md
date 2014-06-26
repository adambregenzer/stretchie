Stretchie
=========

[![Build Status](https://travis-ci.org/adambregenzer/stretchie.png?branch=master)](https://travis-ci.org/adambregenzer/stretchie) [![Coverage Status](https://coveralls.io/repos/adambregenzer/stretchie/badge.png?branch=master)](https://coveralls.io/r/adambregenzer/stretchie?branch=master)

Comfortable searching pants for ActiveRecord Models. Stretchie simplifies
using elastic search in your models and provides hooks to ease testing.


Defining Indices
----------------

Stretchie simply builds on elasticsearch-model, allowing you to pull the
details out into a concern.

With a model like this:
```ruby
class User < ActiveRecord::Base
  attr_accessor :name, :email, :misc_id
end
```

Your concern could look like this:
```ruby
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
```

And you would add this to your model:
```ruby
include Search::User
```

If you have linked models, you can have them re-index automatically with `index_dependent_models`:
```ruby
class User < ActiveRecord::Base
  include Search::User
  attr_accessor :name, :email
  has_may :tags
end

class Tag < ActiveRecord::Base
  include Search::Tag
  attr_accessor :name

  belongs_to :user
end

module Search
  module Tag
    extend ActiveSupport::Concern
    include Stretchie::Pants

    included do
      settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
          indexes :name, analyzer: 'whitespace', index_options: 'offsets'
          indexes :sortable_name
        end
      end
    end

    def as_indexed_json(options={})
      json = as_json(only: [:name])
      json['sortable_name'] = self.name.downcase
      json
    end

    def index_dependent_models
        self.users
    end
  end
end
```


Maintaining Indices
-------------------

Create / Update your indices:
```ruby
Stretchie.update_indices
Stretchie.update_indices :users
```

Delete your indices:
```ruby
Stretchie.delete_indices
Stretchie.delete_indices :users
```

Refresh your indices:
```ruby
Stretchie.refresh_indices
Stretchie.refresh_indices :users
```


Maintaining Documents in the Index
----------------------------------

To add or update changes:
```ruby
user = User.create(name: 'Adam Bregenzer', email: 'adam@bregenzer.net')
user.update_in_index
```

To remove:
```ruby
user.delete_from_index
```


Searching
---------

You can do a simple search:
```ruby
User.search 'Adam'
User.search 'Adam', limit: 10, skip: 20, order: {'name' => 'asc'}
```

You can scope searches:
```ruby
Tag.search 'rails', terms: {'user_id': current_user.id}
```

You can search specific fields:
```ruby
User.field_search :email, 'adam@bregenzer.net'
```

You can search however you want:
```ruby
User.query_search {'match' => {'name' => 'Foo'}}
```


Talk to Me!
-----------

Let me know what you think, if you use it, etc.


Installation
------------

Add this line to your application's Gemfile:

    gem 'stretchie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stretchie


Contributing
------------

1. Fork it ( https://github.com/adambregenzer/stretchie/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
