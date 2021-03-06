require 'rack'
require 'net/http'
require 'jbuilder'

class LeakybucketApp::Server

  attr_accessor :manager, :persistence

  def initialize
    self.manager = Leakybucket::Manager.new
    self.persistence = LeakybucketApp::Persistence.new("db/db.sqlite", self.manager)
    persistence.load
  end

  def bucket params
    bucket = find(params)
    return invalid if bucket.nil?
    render bucket
  end

  def increment params
    bucket = find(params)
    return invalid if bucket.nil?
    bucket.increment
    render bucket
    persistence.persist
  end

  def decrement params
    bucket = find(params)
    return invalid if bucket.nil?
    bucket.decrement
    render bucket
    persistence.persist
  end

  def reset params
    bucket = find(params)
    return invalid if bucket.nil?
    bucket.reset
    render bucket
    persistence.persist
  end

  def find options
    bucket = manager.buckets[options[:key]]
  end

  def create params
    b = find(params)
    if b.nil?
      manager.create_bucket(options)
      b = find(params)
    end
    render b
    persistence.persist
  end

  def render bucket
    Jbuilder.encode do |j|
      j.key bucket.key
      j.value bucket.value
      j.leaking bucket.leaking?
      j.limit bucket.limit
    end
  end

  def invalid msg = 'invalid api call, see: '
    readme = "https://github.com/lukaselmer/leakybucket_app/blob/master/README.md"
    msg += "\n<a href='#{readme}'>#{readme}</a>"
    [404, {'Content-Type' => 'text/html'}, [msg]]
  end

  def routes
    [:bucket, :increment, :decrement, :create, :reset].collect do |v|
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
    return invalid
  end

  def extract_params(env)
    symbolize_keys Rack::Utils.parse_nested_query(env['QUERY_STRING'])
  end

  def symbolize_keys hash
    hash.inject({}) do |result, (key, value)|
      result[key.to_sym] = value.is_a?(Hash) ? symbolize_keys(value) : value
      result
    end
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
