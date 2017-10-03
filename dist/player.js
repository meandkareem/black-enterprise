// Generated by CoffeeScript 1.12.7
(function() {
  (function() {
    var apiRoute, feeds, playerInstance, playlistsTemplate, renderTemplate, setActivePlaylist, setActiveVideo, setPlayerVideo, setupPlayer;
    apiRoute = 'https://cdn.jwplayer.com/v2/playlists/';
    feeds = ['EPKHydfq'];
    playlistsTemplate = $('#js-playlist-template').html();
    playerInstance = void 0;
    setupPlayer = function(thisFeed) {
      playerInstance = jwplayer('player').setup({
        aspectratio: "4:3",
        displaytitle: true,
        logo: false,
        playlist: thisFeed.playlist,
        visualplaylist: true,
        width: '60%'
      });
      playerInstance.on('playlistItem', setActiveVideo);
    };
    setActiveVideo = function(e) {
      var feedid, mediaid;
      feedid = e.item.feedid;
      mediaid = e.item.mediaid;
      $('.js-video-link').removeClass('is-playing').filter(function() {
        return $(this).data('mediaid') === mediaid && $(this).closest('.js-playlist').data('feedid') === feedid;
      }).addClass('is-playing');
    };
    setActivePlaylist = function(e) {
      var captured;
      captured = $(this);
      e.preventDefault();
      if (!captured.hasClass('is-active')) {
        $('.js-playlist-link').removeClass('is-active');
        captured.addClass('is-active');
        $('.js-playlist').removeClass('is-active').filter(function() {
          return $(this).data('feedid') === captured.data('feedid');
        }).addClass('is-active');
      }
    };
    setPlayerVideo = function(e) {
      var captured, currentPlaylist, feedid, mediaid, videoIndex;
      captured = $(this);
      feedid = captured.closest('.js-playlist').data('feedid');
      mediaid = captured.data('mediaid');
      currentPlaylist = feeds.filter(function(thisFeed) {
        return thisFeed.playlist.some(function(thisVideo) {
          return thisVideo.mediaid === mediaid && thisVideo.feedid === feedid;
        });
      }).shift().playlist;
      videoIndex = currentPlaylist.findIndex(function(el) {
        return mediaid === el.mediaid;
      });
      e.preventDefault();
      if (currentPlaylist !== playerInstance.getPlaylist()) {
        playerInstance.load(currentPlaylist);
      }
      playerInstance.playlistItem(videoIndex);
    };
    renderTemplate = function() {
      var playlistsContainer;
      playlistsContainer = $('#js-playlists');
      playlistsContainer.append(Handlebars.compile(playlistsTemplate)(feeds));
      playlistsContainer.on('click', '.js-video-link', setPlayerVideo);
      playlistsContainer.on('click', '.js-playlist-link', setActivePlaylist);
    };
    $.when.apply($, feeds.map(function(feedid) {
      var def;
      def = $.Deferred();
      $.ajax(apiRoute + feedid).done(function(data) {
        def.resolve(data);
      });
      return def.promise();
    })).then(function() {
      feeds = $.makeArray(arguments);
      renderTemplate();
      setupPlayer(feeds[0]);
    });
  })();

}).call(this);
