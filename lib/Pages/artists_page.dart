import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mount_music_player/state/player_state.dart';
import 'package:provider/provider.dart';

import '../ui_colors.dart';
import './custom_songs_page.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class Artists extends StatefulWidget {
  final List<ArtistInfo> artists;
  Artists(this.artists);
  @override
  _ArtistsState createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> with AutomaticKeepAliveClientMixin {
  List<ArtistInfo> artists;
  PageController _pageController;
  Size _screenSize;
  int _currentPage = 0;
  bool active;
  bool isLoading;
  List<SongInfo> songs;

  @override
  void initState() {
    _currentPage = 0;
    isLoading = false;
    _pageController = PageController(initialPage: 0, viewportFraction: 0.7);
    artists = widget.artists;
    songs = [];
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _screenSize = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppBar(
              backgroundColor: darkTheme,
              title: const Text(
                "Artists",
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: marble,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: _screenSize.height * 0.6,
              width: _screenSize.width,
              child: PageView.builder(
                pageSnapping: false,
                controller: _pageController,
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  bool active = _currentPage == index;
                  return getPage(active, index);
                },
                onPageChanged: (int newPage) =>
                    setState(() => _currentPage = newPage),
              ),
            ),
          ],
        ),
        isLoading
            ? const Align(
                alignment: Alignment.center,
                child:
                    const CircularProgressIndicator(backgroundColor: darkTheme),
              )
            : const SizedBox(width: 0, height: 0)
      ],
    );
  }

  AnimatedBuilder getPage(bool active, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) => Container(
          margin: EdgeInsets.symmetric(
              horizontal: 20, vertical: getVerticalMargin(active)),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(getOpacity(active)),
              borderRadius: BorderRadius.circular(10)),
          child: child),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: const Alignment(0, 0.40),
            child: Text(artists[index].name,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 10,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.asset("assets/images/default_album_art.png"),
                      getImage(artists[index].artistArtPath)
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.7, 0.9),
            child: IconButton(
              onPressed: () async {
                await getSongs(artists[index]);
                showDialog(
                  context: context,
                  builder: (context) {
                    return new CustomSongsPage(
                        songs: songs,
                        displayType: "Artist",
                        onTap: updateSongStatus);
                  },
                );
              },
              color: primaryColor,
              icon: Icon(Icons.featured_play_list),
            ),
          ),
          Align(
            alignment: const Alignment(0.7, 0.87),
            child: IconButton(
              onPressed: () async {
                await getSongs(artists[index]);
                Provider.of<AudioPlayerInfo>(context).setCurrentSongList(songs, songs[0].artist);
                Provider.of<AudioPlayerInfo>(context).play();
              },
              icon: const Icon(Icons.play_arrow, size: 36, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  double getVerticalMargin(bool active) {
    if (!_pageController.position.haveDimensions)
      return active ? _screenSize.height * 0.02 : _screenSize.height * 0.07;
    double vertical = (_pageController.page - _currentPage).abs();
    if (active)
      return (vertical * _screenSize.height * 0.05) + _screenSize.height * 0.02;
    else
      return ((1 - vertical) * _screenSize.height * 0.05) +
          _screenSize.height * 0.02;
  }

  double getOpacity(bool active) {
    if (!_pageController.position.haveDimensions) return active ? 0.2 : 0.1;
    double offset = (_pageController.page - _currentPage).abs();
    if (active)
      return 0.2 * (1 - offset) + 0.1;
    else
      return 0.2 * offset + 0.1;
  }

  Image getImage(String path) => path != null
      ? Image.file(
          File(path),
          fit: BoxFit.fill,
        )
      : Image.asset("assets/images/default_album_art.png");

  Future getSongs(ArtistInfo artist) async {
    setState(() {
      isLoading = true;
    });
    FlutterAudioQuery _audioQuery = FlutterAudioQuery();
    songs = await _audioQuery.getSongsFromArtist(artist: artist);
    setState(() {
      isLoading = false;
    });
  }

  void updateSongStatus(int index) {
    Provider.of<AudioPlayerInfo>(context)
        .setCurrentSongList(songs, songs[0].artist);
    Provider.of<AudioPlayerInfo>(context).currentSong = index;
    Provider.of<AudioPlayerInfo>(context).play();
  }
}
