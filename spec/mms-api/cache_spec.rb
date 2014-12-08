require 'mms'

describe MMS::Cache do
  let(:cache) { MMS::Cache.instance }

  it 'should set/get keys' do
    cache.set('key-1', 999)
    cache.set('key-2', 'value')

    cache.get('key-1').should eq(999)
    cache.get('key-2').should eq('value')
  end

  it 'should delete key' do
    cache.set('key-1', 'to_delete')
    cache.delete('key-1')

    cache.get('key-1').should eq(nil)
  end

  it 'should keep key/value into local storage' do
    cache.clear
    cache.set('key-1', 999)
    cache.set('key-2', 'value')

    cache.storage.length.should eq(2)
  end

  it 'should clear storage' do
    cache.set('key-1', 999)
    cache.set('key-2', 'value')
    cache.clear

    cache.storage.should eq({})
  end

end
