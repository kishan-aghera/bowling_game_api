require 'sinatra'
require 'json'

require_relative "bowling_game"

set :bind, '0.0.0.0'
set :port, 3000

before do
  content_type 'application/json'
end

game = BowlingGame.new

post '/start' do
  game = BowlingGame.new
  status 200
  { message: 'New game started.' }.to_json
end

post '/roll' do
  begin
    request_payload = JSON.parse(request.body.read)
    pins = request_payload['pins']
    result = game.roll(pins)
    status 200
    response_body = { message: 'Roll successful.', current_score: game.frames, total_score: game.total_score, last_frame: game.last_frame_type }
    response_body.to_json # Return current score along with spare or strike information
  rescue StandardError => e
    puts e
    status 400
    { error: e.message }.to_json
  end
end

get "/current_score" do
  begin
    status 200
    response_body = { message: "Success", current_score: game.frames[-1][:score], total_score: game.total_score, last_frame: game.last_frame_type }
    response_body.to_json
  rescue StandardError => e
    status 400
    { error: e }.to_json
  end
end
