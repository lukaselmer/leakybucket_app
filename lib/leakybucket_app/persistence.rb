class LeakybucketApp::Persistence

  attr_accessor :manager, :path

  def initialize path, manager
    self.path = path
    self.manager = manager
  end

  def load
     #TODO: impement this
  end

  def persist
    #TODO: impement this
  end
end
