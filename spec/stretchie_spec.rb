#encoding: UTF-8

describe Stretchie do

  context '.update_indices' do

    it 'creates all indices' do
      Stretchie.delete_indices
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).not_to include(User.index_name)
      result = Stretchie.update_indices
      expect(result).to eq(true)
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).to include(User.index_name)
    end

    it 'creates specific indices' do
      Stretchie.delete_indices
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).not_to include(User.index_name)

      result = Stretchie.update_indices :users
      expect(result).to eq(true)
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).to include(User.index_name)
    end

    it 'updates all indices' do
      Stretchie.delete_indices
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).not_to include(User.index_name)

      Stretchie.update_indices
      result = Stretchie.update_indices
      expect(result).to eq(true)
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).to include(User.index_name)
    end

    it 'updates specific indices' do
      Stretchie.delete_indices :users
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).not_to include(User.index_name)

      Stretchie.update_indices :users
      result = Stretchie.update_indices :users
      expect(result).to eq(true)
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).to include(User.index_name)
    end
  end


  context '.delete_indices' do

    it 'deletes all indices' do
      Stretchie.update_indices
      Stretchie.delete_indices
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).not_to include(User.index_name)
    end

    it 'deletes specific indices' do
      Stretchie.delete_indices :users
      indices = User.__elasticsearch__.client.indices.status['indices'].keys
      expect(indices).not_to include(User.index_name)
    end
  end


  context '.refresh_indices' do

    it 'refreshes all indices' do
      result = Stretchie.refresh_indices
      expect(result).to eq(true)
    end

    it 'refreshes specific indices' do
      result = Stretchie.refresh_indices :users
      expect(result).to eq(true)
    end
  end
end
