import 'package:flutter/material.dart';
import 'dart:io';

import '../ui_colors.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';


class CustomSongsPage extends StatefulWidget {
  //final PageController pageController;
  final String displayType;
  final Function onTap;
  const CustomSongsPage(
      {Key key,
      @required this.songs,
      //@required this.pageController,
      @required this.onTap,
      this.displayType})
      : super(key: key);

  final List<SongInfo> songs;

  @override
  _CustomSongsPageState createState() => _CustomSongsPageState();
}

class _CustomSongsPageState extends State<CustomSongsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkTheme,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            backgroundColor: darkTheme,
            expandedHeight: MediaQuery.of(context).size.width,
            flexibleSpace: FlexibleSpaceBar(
              background: getImage(widget.songs[0].albumArtwork),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: primaryColor,
              ),
            ),
            title: Chip(
              backgroundColor: const Color(0xff303030),
              label: Text(
                  widget.displayType == "Album"
                      ? widget.songs[0].album
                      : widget.songs[0].artist,
                  style: listText, overflow: TextOverflow.ellipsis,),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return ListTile(
                leading: const Icon(Icons.library_music, color: primaryColor),
                title: Text(widget.songs[index].title,
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(widget.songs[index].artist,
                    style: TextStyle(color: Colors.white)),
                contentPadding: const EdgeInsets.all(8),
                onTap: () => widget.onTap(index),
              );
            }, childCount: widget.songs.length),
          ),
        ],
      ),
    );
  }

  Image getImage(String path) => path != null
      ? Image.file(
          File(path),
          fit: BoxFit.fill,
        )
      : Image.asset("assets/images/default_album_art.png");
}
