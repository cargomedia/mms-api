require 'mms'

describe MMS::Cache do
  let(:cache) { MMS::Cache.instance }

  it 'should set/get keys' do
    cache.set('key-1', 999)
    cache.set('key-2', 'value')

    expect(cache.get('key-1')).to eq(999)
    expect(cache.get('key-2')).to eq('value')
  end

  it 'should delete key' do
    cache.set('key-1', 'to_delete')
    cache.delete('key-1')

    expect(cache.get('key-1')).to be_nil
  end

  it 'should keep key/value into local storage' do
    cache.clear
    cache.set('key-1', 999)
    cache.set('key-2', 'value')

    expect(cache.storage.length).to eq(2)
  end

  it 'should clear storage' do
    cache.set('key-1', 999)
    cache.set('key-2', 'value')
    cache.clear

    expect(cache.storage).to eq({})
  end
end
