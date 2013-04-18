require 'leakybucket'

describe LeakybucketApp::Server do
  it 'should handle request' do
    s = LeakybucketApp::Server.new
    s.handle_request("xxx")
  end

end

