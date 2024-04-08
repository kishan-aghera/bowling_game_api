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

    if @current_frame < (MAX_FRAMES - 1)
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
    elsif @current_frame == 9
      if @frames[9].nil?
        @frames << { rolls: [pins], score: 0 }
      else
        # Strike on first ball in the last frame
        if frame_rolls_size(@frames.last) == 1 && @frames.last[:rolls][0] == 10
          @frames.last[:rolls] << pins
          calculate_scores
        else
          # Checking if we are only adding 2 additional rolls after strike on 1st chance of last roll
          if @frames.last[:rolls][0] == 10 && frame_rolls_size(@frames.last) < 3
            @frames.last[:rolls] << pins
            calculate_scores
          else
            # If no spare is possible on the 2nd roll then we only allow this time only
            if frame_rolls_size(@frames.last) + 1 == 2 && (@frames.last[:rolls][0] + pins < 10)
              @frames.last[:rolls] << pins
              calculate_scores
              return
            end

            # If no strike nor spare in the 1st 2 rolls, then we are not allowing 3rd roll
            if frame_rolls_size(@frames.last) + 1 == 3 && (@frames.last[:rolls][0] != 10 && @frames.last[:rolls][0] + @frames.last[:rolls][1] != 10)
              raise "Game over! Please start a new game."
            end

            # If we got spare, then we are making sure that only allow the 3rd roll
            if @frames.last[:rolls][0] != 10 && ((@frames.last[:rolls][0] + pins == 10) || frame_rolls_size(@frames.last) == 2)
              @frames.last[:rolls] << pins
              calculate_scores
            else
              raise "Game over! Please start a new game."
            end
          end
        end
      end
    else
      raise "Game over! Please start a new game."
    end
  end

  def calculate_scores
    @frames.each_with_index do |frame, index|
      if index == (MAX_FRAMES - 1)
        frame[:score] = frame_rolls_sum(frame)
      else
        # None
        frame[:score] = frame_rolls_sum(frame)

        # Strike
        if frame[:score] == MAX_SUM_IN_A_FRAME && frame_rolls_size(frame) == NO_OF_CHANCE_FOR_STRIKE_IN_A_FRAME
          # Frames other than last
          if index < (MAX_FRAMES - 1)
            # Adding next frame's rolls to the score
            if @frames[index + 1] && frame_rolls_size(@frames[index + 1]) == MAX_CHANCE_PER_FRAME
              frame[:score] += frame_rolls_sum(@frames[index + 1])
            else
              frame[:score] += @frames[index + 1][:rolls].slice(0, 2).sum if @frames[index + 1]
              # Checking if the next frame is the last frame
              if index + 1 == (MAX_FRAMES - 1)
                # If the previous roll to the latest roll is strike
                if frame[:rolls].last == 10 && frame[:score] < 20
                  frame[:score] += @frames[index + 1][:rolls][0] + @frames[index + 1][:rolls][1] if @frames[index + 1]
                end
              else
                # If the next frame is not last, then we have to add the 1st roll to the current score
                frame[:score] += @frames[index + 2][:rolls].first if @frames[index + 2] && frame[:rolls].last == 10
              end
            end
          else
            # For last, we just want to add the rolls to get the score
            frame[:score] += frame_rolls_sum(@frames[index + 1]) if @frames[index + 1] # Calculate bonus for 10th frame
          end
        # Spare
        elsif frame[:score] == MAX_SUM_IN_A_FRAME && frame[:rolls].size == MAX_CHANCE_PER_FRAME && index < (MAX_FRAMES - 1)
          frame[:score] += @frames[index + 1][:rolls].first if @frames[index + 1]
        end
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
    (frame_rolls_size(frame) == 3 && frame[:rolls][0] == 10) || frame_rolls_sum(frame) == MAX_SUM_IN_A_FRAME && frame_rolls_size(frame) == NO_OF_CHANCE_FOR_STRIKE_IN_A_FRAME
  end

  def spare?(frame)
    (frame_rolls_size(frame) == 3 && frame[:rolls][0] + frame[:rolls][1] == 10) || (frame_rolls_sum(@frames.last) == MAX_SUM_IN_A_FRAME && frame_rolls_size(@frames.last) == MAX_CHANCE_PER_FRAME)
  end

  def frame_rolls_sum(frame)
    frame[:rolls].sum
  end

  def frame_rolls_size(frame)
    frame[:rolls].size
  end
end
