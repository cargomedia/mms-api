require 'mms'

describe MMS::Client do
  let(:client) { MMS::Client.new }

  it 'should return default api uri' do
    client.url.should eq('https://mms.mongodb.com:443/api/public/v1.0')
  end
end
