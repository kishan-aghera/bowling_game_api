require 'sinatra'
require 'json'

set :bind, '0.0.0.0'
set :port, 3000

before do
  content_type 'application/json'
end


get '/' do
  status 200
  { message: 'Success' }.to_json
end
