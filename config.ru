# This file is used by Rack-based servers to start the application.
s = LeakybucketApp::Server.new
run s.handle_request
