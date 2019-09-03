import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

import 'package:mount_music_player/ui_colors.dart';
import 'package:mount_music_player/state/player_state.dart';

class MusicPlayerScreen extends StatefulWidget {
  final AnimationController _animationController;
  final AnimationController _expansionController;
  MusicPlayerScreen(
      this._animationController, this._expansionController);
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  SongInfo song;
  int currentIndex;
  List<SongInfo> songs;

  @override
  void initState() {
    songs = [];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> closeScreen() {
    widget._expansionController.reverse();
    return Future.delayed(Duration(microseconds: 1)).then((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget._expansionController.isAnimating || songs.isEmpty) {
      songs = Provider.of<AudioPlayerInfo>(context).currentPlayingList;
      currentIndex = Provider.of<AudioPlayerInfo>(context).currentIndex;
      song = songs[currentIndex];
    }

    return WillPopScope(
      onWillPop: () => closeScreen(),
      child: Stack(
        children: <Widget>[
          const SizedBox.expand(
            child: const Material(
              color: darkTheme,
            ),
          ),
          Align(
            alignment: const Alignment(-0.95, -0.98),
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              color: primaryColor,
              onPressed: () => widget._expansionController.reverse(),
            ),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.7),
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                song.artist,
                style: const TextStyle(color: Colors.white70, fontSize: 25),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: MainDisplay(songs, currentIndex),
          ),
          PlayControls(widget._animationController, songs.length),
          Align(
              alignment: Alignment.bottomLeft,
              child: SeekBar(songs.length, song.duration))
        ],
      ),
    );
  }
}

class MainDisplay extends StatefulWidget {
  final List<SongInfo> songs;
  final int currentIndex;
  MainDisplay(this.songs, this.currentIndex);

  @override
  _MainDisplayState createState() => _MainDisplayState();
}

class _MainDisplayState extends State<MainDisplay> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: const Radius.circular(50),
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Center(
              child: const Text(
                "Now Playing",
                style: const TextStyle(fontSize: 29),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(
                elevation: 20,
                child: PageView.builder(
                  controller: Provider.of<AudioPlayerInfo>(context)
                      .musicScreenPageController,
                  itemCount: widget.songs.length,
                  onPageChanged: (int page) {
                    setState(() {
                      Provider.of<AudioPlayerInfo>(context).currentSong = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.asset("assets/images/default_album_art.png"),
                        _getImage(widget.songs[index].albumArtwork)
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                Provider.of<AudioPlayerInfo>(context).currentPlayingSong.title,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Text(
              Provider.of<AudioPlayerInfo>(context).currentPlayingSong.album,
              style:
                  TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Image _getImage(String path) => path != null
      ? Image.file(
          File(path),
          fit: BoxFit.fill,
        )
      : Image.asset(
          "assets/images/default_album_art.png",
        );
}

class PlayControls extends StatefulWidget {
  final AnimationController _animationController;
  final int length;
  PlayControls(this._animationController, this.length);

  @override
  _PlayControlsState createState() => _PlayControlsState();
}

class _PlayControlsState extends State<PlayControls>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: const Alignment(-0.6, 0.85),
          child: IconButton(
            icon: const Icon(Icons.skip_previous),
            color: primaryColor,
            onPressed: () {
              int nextPage = Provider.of<AudioPlayerInfo>(context)
                      .musicScreenPageController
                      .page
                      .round() -
                  1;
              nextPage = nextPage < 0 ? widget.length - 1 : nextPage;
              Provider.of<AudioPlayerInfo>(context).skipPrevious();
              Provider.of<AudioPlayerInfo>(context)
                  .musicScreenPageController
                  .animateToPage(nextPage,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOutQuint);
            },
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.85),
          child: Material(
            shape: const CircleBorder(),
            color: primaryColor,
            child: IconButton(
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                size: 30,
                color: darkTheme,
                progress: widget._animationController,
              ),
              onPressed: () => playPause(),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.6, 0.85),
          child: IconButton(
            color: primaryColor,
            icon: const Icon(Icons.skip_next),
            onPressed: () {
              Provider.of<AudioPlayerInfo>(context).skipNext();
              Provider.of<AudioPlayerInfo>(context)
                  .musicScreenPageController
                  .animateToPage(
                      (Provider.of<AudioPlayerInfo>(context)
                                  .musicScreenPageController
                                  .page
                                  .round() +
                              1) %
                          widget.length,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOutQuint);
            },
          ),
        ),
      ],
    );
  }

  void playPause() {
    if (widget._animationController.isCompleted) {
      widget._animationController.reverse();
      Provider.of<AudioPlayerInfo>(context).pause();
    } else if (widget._animationController.isDismissed) {
      widget._animationController.forward();
      Provider.of<AudioPlayerInfo>(context).resume();
    }
  }
}

class SeekBar extends StatefulWidget {
  final int length;
  final String duration;

  SeekBar(this.length, this.duration);
  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double screenHeight;

  @override
  void initState() {
    screenHeight = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (screenHeight.isNegative)
      screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        if (d.delta.dx > 0) {
          Provider.of<AudioPlayerInfo>(context).seekForward();
        }
        if (d.delta.dx < 0) {
          Provider.of<AudioPlayerInfo>(context).seekBackward();
        }
      },
      child: Container(
        height: screenHeight * 0.01,
        width: Provider.of<AudioPlayerInfo>(context).durationPlayedPercent *
            MediaQuery.of(context).size.width,
        color: primaryColor,
        child: Container(),
      ),
    );
  }
}
