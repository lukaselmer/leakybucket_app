# This file is used by Rack-based servers to start the application.
require File.expand_path('lib/leakybucket_app')
s = LeakybucketApp::Server.new
run s.request_handler
