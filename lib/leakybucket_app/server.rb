require 'leakybucket'

class LeakybucketApp::Server

  def initialize
    self.manager = Leakybucket::Manager.new
  end

  def handle_request params
    "bla bla bla"
  end

end