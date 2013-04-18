require 'rack'
require 'net/http'
require 'jbuilder'

class LeakybucketApp::Server

  attr_accessor :manager

  def initialize
    self.manager = Leakybucket::Manager.new
  end

  def value params
    bucket = find_or_create(params)
    render bucket
  end

  def increment params
    bucket = find_or_create(params)
    bucket.increment
    render bucket
  end

  def decrement params
    bucket = find_or_create(params)
    bucket.decrement
    render bucket
  end

  def find_or_create options
    bucket = manager.buckets[options["key"]]
    bucket.nil? ? manager.create_bucket(options) : bucket
  end

  def create params
    b = find_or_create(params)
    render b
  end

  def render bucket
    Jbuilder.encode do |j|
      j.key bucket.key
      j.value bucket.value
      j.leaking bucket.leaking?
    end
  end

  def invalid msg = 'not found'
    [404, {'Content-Type' => 'text/plain'}, ['not found']]
  end

  def routes
    [:value, :increment, :decrement, :create].collect do |v|
      ["/#{v}", ->(params) { send(v, params) }]
    end
  end

  def handle_request env
    params = extract_params(env)
    routes.each do |k, v|
      if k == env['REQUEST_PATH']
        res = v.(params)
        return res.is_a?(Array) ? res : [200, {'Content-Type' => 'application/json'}, [res]]
      end

    end
    return invalid('not found')
  end

  def extract_params(env)
    return Rack::Utils.parse_nested_query(env['QUERY_STRING'])
  end

  def request_handler
    handler = lambda do |env|
      handle_request(env)
    end
    Rack::Builder.new do
      use Rack::Reloader, 0
      use Rack::ContentLength
      use Rack::CommonLogger

      run handler
    end.to_app
  end

end
