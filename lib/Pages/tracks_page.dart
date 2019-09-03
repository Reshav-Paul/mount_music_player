//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui_colors.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:mount_music_player/state/player_state.dart';
import '../Widgets/custom_expansion_tile.dart';

class Tracks extends StatefulWidget {
  final List<SongInfo> songs;
  Tracks(this.songs);
  @override
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<Tracks> with AutomaticKeepAliveClientMixin {
  final TextStyle textStyle = TextStyle(color: Colors.white);
  List<SongInfo> songs;

  @override
  void initState() {
    songs = widget.songs;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkTheme,
          floating: true,
          title: const Text("Tracks",
              textAlign: TextAlign.left,
              style: const TextStyle(
                  color: marble, fontSize: 25.0, fontWeight: FontWeight.bold)),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => CustomExpansionTile(
                  onTap: () {
                    Provider.of<AudioPlayerInfo>(context)
                        .setCurrentSongList(songs, "Tracks");
                    Provider.of<AudioPlayerInfo>(context).currentSong = index;
                    Provider.of<AudioPlayerInfo>(context).play();
                  },
                  song: songs[index],
                  addToPlaylist: () => showPlaylistsDialog(songs[index]),
                ),
            childCount: songs.length,
          ),
        )
      ],
    );
  }

  void showPlaylistsDialog(SongInfo song) {
    List<PlaylistInfo> playlists = Provider.of<AudioData>(context).playlists;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            title: const Text("Playlists",
                style: const TextStyle(
                    color: marble,
                    fontSize: 21.0,
                    fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xff303030),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.4,
              child: ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (dialogContext, index) {
                  return ListTile(
                    title: Text(playlists[index].name, style: listText),
                    subtitle: Text(
                        playlists[index].memberIds.length.toString() + "Tracks",
                        style: TextStyle(color: Colors.white70)),
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      addSongToPlaylist(playlists[index], song);
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  void addSongToPlaylist(PlaylistInfo playlist, SongInfo song) async {
    if (playlist.memberIds.contains(song.id))
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 1500),
        backgroundColor: const Color(0xff303030),
        content: Text("Track already present in ${playlist.name}"),
      ));
    else {
      int index = Provider.of<AudioData>(context).playlists.indexOf(playlist);
      await Provider.of<AudioData>(context).playlists[index].addSong(song: song);
      Provider.of<AudioData>(context).refresh();
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 1500),
        backgroundColor: const Color(0xff303030),
        content: Text("Added Successfully"),
      ));
    }
  }
}
