class BowlingGame
  MAX_FRAMES = 10
  MAX_CHANCE_PER_FRAME = 2
  NO_OF_CHANCE_FOR_STRIKE_IN_A_FRAME = 1
  MAX_SUM_IN_A_FRAME = 10

  attr_reader :frames, :current_frame

  def initialize
    @frames = []
    @current_frame = 0
  end

  def roll(pins)
    if pins > 10
      raise "Pins should be less than or equal to 10"
      return
    end

    if @current_frame < MAX_FRAMES
      if @frames.empty? ||
        frame_rolls_size(@frames.last) == MAX_CHANCE_PER_FRAME ||
        (frame_rolls_sum(@frames.last) + pins) > MAX_SUM_IN_A_FRAME

        @frames << { rolls: [pins], score: 0 } # Start a new frame if necessary
      else
        @frames.last[:rolls] << pins # Add roll to the current frame
      end

      calculate_scores

      # Move to the next frame if necessary
      @current_frame += 1 if frame_rolls_size(@frames.last) == MAX_CHANCE_PER_FRAME || frame_rolls_sum(@frames.last) == MAX_SUM_IN_A_FRAME
    else
      raise "Game over! Please start a new game."
    end
  end

  def calculate_scores
    @frames.each_with_index do |frame, index|
      # If frame is neither strike nor spare
      frame[:score] = frame_rolls_sum(frame)

      # Adding bonus for spare/strike if there is one
      # If current frame is strike
      if frame[:score] == MAX_SUM_IN_A_FRAME && frame_rolls_size(frame) == NO_OF_CHANCE_FOR_STRIKE_IN_A_FRAME
        if index < (MAX_FRAMES - 1)
          if @frames[index + 1] && frame_rolls_size(@frames[index + 1]) == MAX_CHANCE_PER_FRAME
            frame[:score] += frame_rolls_sum(@frames[index + 1])
          else
            frame[:score] += frame_rolls_sum(@frames[index + 1]) if @frames[index + 1]
            frame[:score] += @frames[index + 2][:rolls].first if @frames[index + 2] && frame_rolls_size(@frames[index + 2]) == 1 # Calculate bonus for strike
          end
        else
          frame[:score] += frame_rolls_sum(@frames[index + 1]) if @frames[index + 1] # Calculate bonus for 10th frame
        end
      # If current frame is spare
      elsif frame[:score] == MAX_SUM_IN_A_FRAME && frame[:rolls].size == MAX_CHANCE_PER_FRAME && index < (MAX_FRAMES - 1)
        frame[:score] += @frames[index + 1][:rolls].first if @frames[index + 1]
      end
    end
  end

  def total_score
    @frames.sum { |frame| frame[:score] }
  end

  def current_score
    @frames.last[:score]
  end

  def last_frame_type
    if spare?(@frames.last)
      'spare'
    elsif strike?(@frames.last)
      'strike'
    else
      'none'
    end
  end

  private

  def strike?(frame)
    frame_rolls_sum(frame) == MAX_SUM_IN_A_FRAME && frame_rolls_size(frame) == NO_OF_CHANCE_FOR_STRIKE_IN_A_FRAME
  end

  def spare?(frame)
    frame_rolls_sum(@frames.last) == MAX_SUM_IN_A_FRAME && frame_rolls_size(@frames.last) == MAX_CHANCE_PER_FRAME
  end

  def frame_rolls_sum(frame)
    frame[:rolls].sum
  end

  def frame_rolls_size(frame)
    frame[:rolls].size
  end
end
