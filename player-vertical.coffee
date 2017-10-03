do ->
  apiRoute = 'https://cdn.jwplayer.com/v2/playlists/'
  feeds = [
    'QULlOxeC'
    '7SlteGRg'
  ]
  playlistsTemplate = $('#js-playlist-template').html()
  playerInstance = undefined

  setupPlayer = (thisFeed) ->
    # Initialize the player
    playerInstance = jwplayer('player').setup(
      aspectratio: "4:3"
      displaytitle: true
      logo: false
      playlist: thisFeed.playlist
      visualplaylist: true
      width: '100%')
    # Change the highlighted item in the playlist when the video changes
    playerInstance.on 'playlistItem', setActiveVideo
    return

  setActiveVideo = (e) ->
    feedid = e.item.feedid
    mediaid = e.item.mediaid
    $('.js-video-link').removeClass('is-playing').filter(->
      $(this).data('mediaid') == mediaid and $(this).closest('.js-playlist').data('feedid') == feedid
    ).addClass 'is-playing'
    return

  setActivePlaylist = (e) ->
    # Switch the visible playlist when its label is clicked
    captured = $(this)
    e.preventDefault()
    if !captured.hasClass('is-active')
      # Change the active playlist link
      $('.js-playlist-link').removeClass 'is-active'
      captured.addClass 'is-active'
      # Change the active visible playlist
      $('.js-playlist').removeClass('is-active').filter(->
        $(this).data('feedid') == captured.data('feedid')
      ).addClass 'is-active'
    return

  setPlayerVideo = (e) ->
    captured = $(this)
    feedid = captured.closest('.js-playlist').data('feedid')
    mediaid = captured.data('mediaid')
    # Gotta get the right playlist for this particular video link
    currentPlaylist = feeds.filter((thisFeed) ->
      thisFeed.playlist.some (thisVideo) ->
        thisVideo.mediaid == mediaid and thisVideo.feedid == feedid
    ).shift().playlist
    # Get the index of the video that matches this link's mediaid
    videoIndex = currentPlaylist.findIndex((el) ->
      mediaid == el.mediaid
    )
    e.preventDefault()
    # Only load this playlist if the player's current playlist is different
    if currentPlaylist != playerInstance.getPlaylist()
      playerInstance.load currentPlaylist
    # Tell the player to play the video at this playlist index
    playerInstance.playlistItem videoIndex
    return

  renderTemplate = ->
    playlistsContainer = $('#js-playlists')
    playlistsContainer.append Handlebars.compile(playlistsTemplate)(feeds)
    # Create a delegate click event for playlist items
    playlistsContainer.on 'click', '.js-video-link', setPlayerVideo
    playlistsContainer.on 'click', '.js-playlist-link', setActivePlaylist
    return

  $.when.apply($, feeds.map((feedid) ->
    # Use jQuery Deferreds to make sure all of the feeds are loaded before
    # rendering them or trying to initialize the player.
    def = $.Deferred()
    $.ajax(apiRoute + feedid).done (data) ->
      def.resolve data
      return
    def.promise()
  )).then ->
    # replace the feeds array with all of the now-fetched feed objects
    feeds = $.makeArray(arguments)
    renderTemplate()
    setupPlayer feeds[0]
    return
  return
