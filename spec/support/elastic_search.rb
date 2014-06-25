RSpec.configure do |config|
  config.before(:each) do
    Stretchie.update_indices
  end

  config.append_after(:each) do
    Stretchie.delete_indices
  end
end
