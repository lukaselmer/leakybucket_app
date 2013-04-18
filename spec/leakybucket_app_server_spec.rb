require 'leakybucket_app'

describe LeakybucketApp::Server do
  it 'should handle invalid request' do
    s = LeakybucketApp::Server.new
    res = s.handle_request('xxx')
    res[2][0].should eql('not found')
  end
end

