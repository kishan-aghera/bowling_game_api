require_relative '../bowling_game'

RSpec.describe BowlingGame do
  let(:game) { described_class.new }

  describe "#roll" do
    context "when rolling a ball" do
      it "adds pins to the current frame" do
        game.roll(4)
        expect(game.frames.last[:rolls]).to include(4)
      end

      it "moves to the next frame if necessary" do
        expect {
          20.times { game.roll(1) }
        }.to change { game.current_frame }.from(0).to(10)
      end

      it "raises an error when the game is over" do
        20.times { game.roll(0) }
        expect { game.roll(0) }.to raise_error("Game over! Please start a new game.")
      end

      it 'raises an error if the roll entered is >= 10' do
        expect { game.roll(11) }.to raise_error("Pins should be less than or equal to 10")
      end
    end
  end

  describe "#calculate_scores" do
    context "when calculating scores" do
      it "calculates the total score correctly" do
        10.times { game.roll(4) }
        expect(game.total_score).to eq(40)
      end

      it "handles spares correctly" do
        game.roll(5)
        game.roll(5) # spare
        game.roll(3)
        expect(game.total_score).to eq(16) # 5 + 5 + 3 + 3
      end

      it "handles strikes correctly" do
        game.roll(10) # strike
        game.roll(4)
        game.roll(3)
        expect(game.total_score).to eq(24) # 10 + 4 + 3 + 4 + 3
      end
    end
  end

  describe "#last_frame_type" do
    context "when determining the type of the last frame" do
      it "returns 'spare' if the last frame is a spare" do
        game.roll(5)
        game.roll(5) # spare
        expect(game.last_frame_type).to eq('spare')
      end

      it "returns 'strike' if the last frame is a strike" do
        game.roll(10) # strike
        expect(game.last_frame_type).to eq('strike')
      end

      it "returns 'none' if the last frame is neither a spare nor a strike" do
        game.roll(3)
        game.roll(4)
        expect(game.last_frame_type).to eq('none')
      end
    end
  end
end
