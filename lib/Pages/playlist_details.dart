import 'package:flutter/material.dart';
import 'dart:io';

import '../ui_colors.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class PlaylistDetails extends StatefulWidget {
  final PlaylistInfo playlist;
  final List<SongInfo> songs;
  final Function removeSongFromPlaylist;
  final Function onTap;
  PlaylistDetails(
      {this.playlist, this.songs, this.removeSongFromPlaylist, this.onTap});

  @override
  _PlaylistDetailsState createState() => _PlaylistDetailsState();
}

class _PlaylistDetailsState extends State<PlaylistDetails> {
  List<SongInfo> songs;
  @override
  void initState() {
    songs = widget.songs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff303030),
        title: Text(widget.playlist.name),
      ),
      backgroundColor: darkTheme,
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              height: 50,
              width: 55,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset("assets/images/default_album_art.png"),
                  Container(
                      width: double.infinity,
                      child: getImage(widget.songs[index].albumArtwork)),
                ],
              ),
            ),
            //leading: getImage(widget.songs[index].albumArtwork),
            title: Text(
              songs[index].title,
              style: listText,
            ),
            subtitle: Text(
              songs[index].artist,
              style: TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_sweep,
                color: primaryColor,
              ),
              onPressed: () {
                widget.removeSongFromPlaylist(widget.playlist, songs[index]);
                setState(() {
                  songs.remove(songs[index]);
                });
              },
            ),
            onTap: () => widget.onTap(songs, index),
          );
        },
      ),
    );
  }

  Image getImage(path) => path != null
      ? Image.file(
          File(path),
          width: 55,
          height: 50,
          fit: BoxFit.fill,
        )
      : Image.asset("assets/images/default_album_art.png");
}
