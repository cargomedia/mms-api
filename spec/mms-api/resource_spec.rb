require 'mms'

describe MMS::Resource do
  let(:resource) { MMS::Resource.new }

  it 'should return default cache_key for resource' do
    expect(resource.send(:cache_key, 'myresource')).to eq('Class::MMS::Resource:myresource')
  end
end
