#encoding: UTF-8

describe Stretchie::Pants do

  before :each do
    @user = User.create(name: 'Foo Bar', email: 'baz@baz.com', misc_id: 100)
    @user.update_in_index
    @user1 = User.create(name: 'Red Green', email: 'blue@white.com' )
    @user1.update_in_index
    @user2 = User.create(name: 'Red Purple', email: 'red@white.com' )
    @user2.update_in_index
    Stretchie.refresh_indices
  end


  context '.delete_from_index' do
    it 'removes document from index' do
      @user.delete_from_index
      Stretchie.refresh_indices
      results = User.search 'Foo'
      results = results.records.to_a
      expect(results.length).to eq(0)
      expect(results).to eq([])
      @user.delete_from_index
    end
  end
  context '.update_in_index' do
    it 'adds documents to the index' do
      @user.delete_from_index
      Stretchie.refresh_indices
      results = User.search 'Foo'
      results = results.records.to_a
      expect(results.length).to eq(0)
      expect(results).to eq([])

      @user.update_in_index
      Stretchie.refresh_indices
      results = User.search 'Foo'
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end
  end

  context '.search' do

    it 'searches all fields' do
      results = User.search 'Foo'
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])

      results = User.search 'baz@baz.com'
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end

    it 'searches all fields with invalid query characters' do
      results = User.search 'Foo"'
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end

    it 'searches specific fields' do
      results = User.search 'Foo', fields: :name
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end

    it 'requires specific terms' do
      results = User.search 'baz@baz.com', terms: {misc_id: 100}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end

    it 'supports limit' do
      results = User.search 'Red', limit: 1, order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user1])
    end

    it 'supports skip' do
      results = User.search 'Red', limit: 1, skip: 1, order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user2])
    end

    it 'supports order' do
      results = User.search 'Red', order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(2)
      expect(results).to eq([@user1, @user2])
    end
  end


  context '.field_search' do
    it 'searches all fields' do
      results = User.field_search :name, 'Foo'
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])

      results = User.field_search :name, 'baz@baz.com'
      results = results.records.to_a
      expect(results.length).to eq(0)
      expect(results).to eq([])
    end

    it 'requires specific terms' do
      results = User.field_search :name, 'Foo', terms: {misc_id: 100}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end

    it 'supports limit' do
      results = User.field_search :name, 'Red', limit: 1, order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user1])
    end

    it 'supports skip' do
      results = User.field_search :name, 'Red', limit: 1, skip: 1, order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user2])
    end

    it 'supports order' do
      results = User.field_search :name, 'Red', order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(2)
      expect(results).to eq([@user1, @user2])
    end
  end


  context '.query_search' do
    it 'performs a custom search' do
      query = {
        'match' => {
            'name' => 'Foo'
        }
      }

      results = User.query_search query
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end

    it 'requires specific terms' do
      query = {
        'match' => {
            'name' => 'Foo'
        }
      }

      results = User.query_search query, terms: {misc_id: 100}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end

    it 'requires additional terms' do
      query = {
        'term' => {
            'name' => 'Foo'
        }
      }

      results = User.query_search query, terms: {misc_id: 100}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user])
    end

    it 'supports limit' do
      query = {
        'match' => {
            'name' => 'Red'
        }
      }

      results = User.query_search query, limit: 1, order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user1])
    end

    it 'supports skip' do
      query = {
        'match' => {
            'name' => 'Red'
        }
      }

      results = User.query_search query, limit: 1, skip: 1, order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(1)
      expect(results).to eq([@user2])
    end

    it 'supports order' do
      query = {
        'match' => {
            'name' => 'Red'
        }
      }

      results = User.query_search query, order: {'name' => 'asc'}
      results = results.records.to_a
      expect(results.length).to eq(2)
      expect(results).to eq([@user1, @user2])
    end
  end
end
