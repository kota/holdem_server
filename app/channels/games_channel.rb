class GamesChannel < ApplicationCable::Channel
  def join(data)
    stop_all_streams
    stream_from "games:#{data['game_id'].to_i}:#{data['user_id'].to_i}"
  end

  def leave
    stop_all_streams
  end
end
