import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_audio_query/flutter_audio_query.dart';

import '../ui_colors.dart';

class CustomExpansionTile extends StatefulWidget {
  final Function onTap;
  final SongInfo song;
  final Function addToPlaylist;
  CustomExpansionTile({this.onTap, this.song, this.addToPlaylist});
  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation expandAnimation;
  double height;
  Image image;
  bool imageConfirmed;
  @override
  initState() {
    super.initState();
    imageConfirmed = false;
    image = Image.asset("assets/images/default_album_art.png");
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    expandAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.ease));
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    if(!imageConfirmed)
      getImage();
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        height = screenHeight * 0.1 * expandAnimation.value;
        return Column(
          children: <Widget>[
            child,
            Container(
              color: const Color(0xff303030),
              height: height,
              child: height > screenHeight * 0.09
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          //color: primaryColor,
                          onPressed: () => showDetailsDialog(),
                          child: Text(
                            "Details",
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                        FlatButton(
                          //color: primaryColor,
                          onPressed: () => widget.addToPlaylist(),
                          child: Text(
                            "Add to Playlist",
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ),
          ],
        );
      },
      child: ListTile(
        leading: image,
        title: Text(
          widget.song.title,
          style: listText,
        ),
        subtitle: Text(
          widget.song.artist,
          style: const TextStyle(color: Colors.white70),
        ),
        onTap: widget.onTap,
        trailing: IconButton(
          icon: AnimatedIcon(
            progress: _animationController,
            icon: AnimatedIcons.menu_close,
            color: primaryColor,
          ),
          onPressed: () {
            if (expandAnimation.isDismissed)
              _animationController.forward();
            else
              _animationController.reverse();
          },
        ),
        contentPadding: const EdgeInsets.all(2),
      ),
    );
  }

  void getImage() async{
    if(widget.song.albumArtwork == null){
      setState(() => imageConfirmed = true);
      return;
    }
    File(widget.song.albumArtwork).exists().then((e){
      if(e == true)
        image = Image.file(File(widget.song.albumArtwork));
        setState(() => imageConfirmed = true);
    });
  }

  void showDetailsDialog() {
    int minutes = (double.parse(widget.song.duration) / 60000).floor();
    int sec =
        (double.parse(widget.song.duration) / 1000).floor() - minutes * 60;
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xff303030),
            title: Text("Properties",
                style: const TextStyle(
                    color: marble,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Title - " + widget.song.title, style: listText),
                Text("Artist - " + widget.song.artist, style: listText),
                Text("Album - " + widget.song.album, style: listText),
                Text("Duration - " + minutes.toString() + ":" + sec.toString(),
                    style: listText),
                widget.song.year != null
                    ? Text("Year - " + widget.song.year, style: listText)
                    : SizedBox(),
                Text(
                    "Size - " +
                        (double.parse(widget.song.fileSize) / 1e6)
                            .toStringAsFixed(2) +
                        " mb",
                    style: listText),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                color: primaryColor,
                child: Text("Done",
                    style: const TextStyle(color: const Color(0xff303030))),
                onPressed: () => Navigator.of(dialogContext).pop(),
              )
            ],
          );
        });
  }
}
