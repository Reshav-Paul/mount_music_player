import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mount_music_player/state/player_state.dart';
import 'package:provider/provider.dart';

import '../ui_colors.dart';
import './custom_songs_page.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class Albums extends StatefulWidget {
  final List<AlbumInfo> albums;
  Albums(this.albums);
  @override
  _AlbumsState createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> with AutomaticKeepAliveClientMixin {
  List<AlbumInfo> albums;
  AlbumInfo selectedAlbum;
  //PageController _pageController;
  bool isLoading;
  List<SongInfo> songs;
  @override
  void initState() {
    isLoading = false;
    //_pageController = PageController();
    albums = widget.albums;
    selectedAlbum = albums[0];
    songs = [];
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: darkTheme,
              floating: true,
              title: const Text("Albums",
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: marble,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold)),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15),
              delegate: SliverChildBuilderDelegate(
                  (context, index) => _getGrid(index),
                  childCount: albums.length),
            )
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

  Image getImage(index) {
    Image image;
    try {
      image = albums[index].albumArt != null
          ? Image.file(File(albums[index].albumArt), fit: BoxFit.fill)
          : Image.asset("assets/images/default_album_art.png");
    } on Error {
      print("Error");
    }
    return image;
  }

  GestureDetector _getGrid(int index) {
    return GestureDetector(
      onTap: () => getSongs(albums[index]),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset("assets/images/default_album_art.png"),
            getImage(index)
          ],
        ),
      ),
    );
  }

  Future getSongs(AlbumInfo album) async {
    setState(() {
      isLoading = true;
    });
    FlutterAudioQuery _audioQuery = FlutterAudioQuery();
    songs = await _audioQuery.getSongsFromAlbum(album: album);
    setState(() {
      isLoading = false;
    });
    showDialog(
      context: context,
      builder: (context) {
        return new CustomSongsPage(
            songs: songs, displayType: "Album", onTap: updateSongStatus);
      },
    );
  }

  void updateSongStatus(int index) {
    Provider.of<AudioPlayerInfo>(context)
        .setCurrentSongList(songs, songs[0].album);
    Provider.of<AudioPlayerInfo>(context).currentSong = index;
    Provider.of<AudioPlayerInfo>(context).play();
  }
}
