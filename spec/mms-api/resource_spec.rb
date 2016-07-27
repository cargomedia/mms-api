require 'mms'

describe MMS::Resource do
  let(:resource) { MMS::Resource.new }

  it 'should return default cache_key for resource' do
    resource.send(:cache_key, 'myresource').should eq('Class::MMS::Resource:myresource')
  end
end
