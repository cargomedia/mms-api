require 'mms'

describe MMS::Client do
  let(:client) { MMS::Client.instance }

  it 'should return default api uri' do
    client.site.should eq('https://mms.mongodb.com:443/api/public/v1.0')
  end
end
