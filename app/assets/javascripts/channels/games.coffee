App.games = App.cable.subscriptions.create "GamesChannel",

  connected: ->
    setTimeout =>
      @join()
    , 1000

  received: (data) ->
    $(hand).html(data.hand)
    if data.my_action
      $(hand_control).show()
    else
      $(hand_control).hide()

  join: ->
    if game_id = $(game).attr('data-game-id')
      @perform 'join', game_id: game_id, user_id: $('meta[name=current-user]').attr('id')
    else
      @perform 'leave'
