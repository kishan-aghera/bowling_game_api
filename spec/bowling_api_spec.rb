require "rack/test"

require_relative "../bowling_game"
require_relative "../server"

RSpec.describe "Bowling Game API" do
  include Rack::Test::Methods

  let(:app) { Sinatra::Application }

  def post_roll(pins)
    post '/roll', { pins: pins }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'POST /start' do
    it 'starts a new game' do
      post '/start'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['message']).to eq('New game started.')
    end
  end

  describe 'GET /current_score' do
    before do
      post '/start'
      expect(last_response.status).to eq(200)
    end

    it 'shows correct current_score' do
      post_roll(5)
      post_roll(5)
      post_roll(5)
      last_response = get '/current_score'
      response_body = JSON.parse(last_response.body)
      expect(response_body['current_score']).to eq(5)
      expect(response_body['total_score']).to eq(20)
    end
  end

  describe 'POST /roll' do
    context 'when rolling without strikes or spares' do
      before do
        post '/start'
        expect(last_response.status).to eq(200)
      end

      it 'records rolls and returns current score' do
        last_response = post_roll(4)
        response_body = JSON.parse(last_response.body)
        expect(response_body['current_score']).not_to be_empty
        expect(response_body['total_score']).to eq(4)
        expect(response_body['last_frame']).to eq('none')
      end

      it 'handles multiple rolls and calculates scores accurately' do
        post_roll(3)
        post_roll(5)
        post_roll(2)
        last_response = post_roll(4)

        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(14)
      end
    end

    context 'when rolling a strike' do
      before do
        post '/start'
        expect(last_response.status).to eq(200)
      end

      it 'records a strike and returns current score' do
        last_response = post_roll(10) # Strike
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body['message']).to eq('Roll successful.')
        expect(response_body['current_score']).not_to be_empty
        expect(response_body['total_score']).to eq(10)
        expect(response_body['last_frame']).to eq('strike')
      end

      it 'handles multiple strikes and calculates scores accurately' do
        last_response = post_roll(10)
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(10)

        last_response = post_roll(10)
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(30)

        last_response = post_roll(10)
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(60)

        last_response = post_roll(10)
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(90)
      end
    end

    context 'when rolling a spare' do
      before do
        post '/start'
        post_roll(5)
      end

      it 'records a spare and returns current score' do
        last_response = post_roll(5)
        response_body = JSON.parse(last_response.body)
        expect(response_body['message']).to eq('Roll successful.')
        expect(response_body['current_score']).not_to be_empty
        expect(response_body['total_score']).to eq(10)
        expect(response_body['last_frame']).to eq('spare')
      end

      it 'handles multiple spares and calculates scores accurately' do
        post_roll(5)
        post_roll(5)
        last_response = post_roll(5)

        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(25)
      end
    end

    context 'when attempting to roll after the game is over' do
      before do
        post '/start'
        expect(last_response.status).to eq(200)
        20.times { post_roll(4) }
      end

      it 'returns an error message' do
        last_response = post_roll(4)
        expect(JSON.parse(last_response.body)['error']).to eq('Game over! Please start a new game.')
      end
    end

    context 'complete game with both strike & spare' do
      before do
        post '/start'
        expect(last_response.status).to eq(200)
      end

      # 4	5	3	2	9	/	2	2	×	6	2	8	1	×	2	5	×
      it 'should work' do
        last_response = post_roll(4)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(4)

        last_response = post_roll(5)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(9)

        last_response = post_roll(3)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(12)

        last_response = post_roll(2)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(14)

        last_response = post_roll(9)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(23)

        last_response = post_roll(1)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(24)

        last_response = post_roll(2)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(28)

        last_response = post_roll(2)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(30)

        last_response = post_roll(10)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(40)

        last_response = post_roll(6)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(52)

        last_response = post_roll(2)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(56)

        last_response = post_roll(8)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(64)

        last_response = post_roll(1)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(65)

        last_response = post_roll(10)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(75)

        last_response = post_roll(2)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(79)

        last_response = post_roll(5)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(89)

        last_response = post_roll(10)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(89)

        last_response = post_roll(10)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(109)

        last_response = post_roll(10)
        response_body = JSON.parse(last_response.body)
        expect(response_body['total_score']).to eq(119)

        # 21st frame
        last_response = post_roll(4)
        response_body = JSON.parse(last_response.body)
        expect(JSON.parse(last_response.body)['error']).to eq('Game over! Please start a new game.')
      end
    end
  end
end
