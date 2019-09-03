import 'package:flutter/material.dart';
//import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

import '../ui_colors.dart';
import 'package:mount_music_player/state/player_state.dart';
import './playlist_details.dart';

class Playlists extends StatefulWidget {
  final List<PlaylistInfo> playlists;
  Playlists(this.playlists);
  @override
  _PlaylistsState createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists>
    with AutomaticKeepAliveClientMixin {
  List<PlaylistInfo> playlists;
  TextStyle textStyle;
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    playlists = widget.playlists;
    textStyle = TextStyle(color: Colors.white);
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (playlists.isEmpty)
      return Scaffold(
        appBar: AppBar(
          backgroundColor: darkTheme,
          title: Text(
            "Playlists",
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: marble, fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Text("I feel Empty!", style: textStyle),
        ),
        backgroundColor: darkTheme,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.playlist_add),
          onPressed: () => _getAddButton(),
        ),
      );
    else
      return Scaffold(
        appBar: null,
        backgroundColor: darkTheme,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.playlist_add),
          onPressed: () => _getAddButton(),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: darkTheme,
              floating: true,
              title: const Text("Playlists",
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: marble,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold)),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return ListTile(
                  dense: false,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                  title: Text(playlists[index].name, style: textStyle),
                  subtitle: Text(
                      playlists[index].memberIds.length.toString() + " tracks",
                      style: TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_forever, color: primaryColor),
                    onPressed: () async {
                      PlaylistInfo playlistInfo =
                          Provider.of<AudioData>(context).playlists[index];
                      Provider.of<AudioData>(context)
                          .removePlaylist(playlists[index]);
                      await FlutterAudioQuery.removePlaylist(
                          playlist: playlistInfo);
                    },
                  ),
                  onTap: () => showSongsDialog(playlists[index]),
                );
              }, childCount: playlists.length),
            )
          ],
        ),
      );
  }

  void _getAddButton() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Create Playlist"),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          elevation: 10,
          backgroundColor: const Color(0xff303030),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Enter playlist name",
              hintStyle: TextStyle(color: Colors.white30),
            ),
            style: textStyle,
            keyboardType: TextInputType.text,
            keyboardAppearance: Brightness.dark,
            onSubmitted: (name) async {
              if (name.length > 0) createNewPlaylist(name);
              _controller.clear();
              Navigator.of(dialogContext).pop();
            },
          ),
          actions: <Widget>[
            FlatButton(
              color: primaryColor,
              onPressed: () {
                if (_controller.text.length > 0)
                  createNewPlaylist(_controller.text);
                _controller.clear();
                Navigator.of(dialogContext).pop();
              },
              child: Text("Create", style: TextStyle(color: darkTheme)),
            )
          ],
        );
      },
    );
  }

  void createNewPlaylist(String name) async {
    try {
      PlaylistInfo playlist =
          await FlutterAudioQuery.createPlaylist(playlistName: name);
      Provider.of<AudioData>(context).addPlaylist(playlist);
    } on Exception {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Playlist with this name already exists"),
          backgroundColor: const Color(0xff303030),
        ),
      );
    }
  }

  void showSongsDialog(PlaylistInfo playlist) async {
    FlutterAudioQuery audioQuery = FlutterAudioQuery();
    List<SongInfo> songs =
        await audioQuery.getSongsFromPlaylist(playlist: playlist);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaylistDetails(
              playlist: playlist,
              songs: songs,
              removeSongFromPlaylist: removeSongFromPlaylist,
              onTap: onTap,
            ),
      ),
    );
  }

  void removeSongFromPlaylist(PlaylistInfo playlist, SongInfo song) async {
    int index = Provider.of<AudioData>(context).playlists.indexOf(playlist);
    Provider.of<AudioData>(context).playlists[index].removeSong(song: song);
  }

  void onTap(List<SongInfo> songs, int index) {
    Provider.of<AudioPlayerInfo>(context).currentPlayingList = songs;
    Provider.of<AudioPlayerInfo>(context).currentSong = index;
    Provider.of<AudioPlayerInfo>(context).currentPage = "Playlists";
    Provider.of<AudioPlayerInfo>(context).play();
  }
}
