import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mount_music_player/Widgets/music_player_screen.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../ui_colors.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:mount_music_player/state/player_state.dart';

class BottomPlayArea extends StatefulWidget {
  final TabController _tabController;
  BottomPlayArea(this._tabController);
  @override
  _BottomPlayAreaState createState() => _BottomPlayAreaState();
}

class _BottomPlayAreaState extends State<BottomPlayArea>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _expansionController;
  Animation<double> _expandAnimation;
  SongInfo song;
  int currentIndex;

  //@override
  //bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _expansionController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _expandAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: _expansionController, curve: Curves.ease));
  }

  @override
  void dispose() {
    _controller.dispose();
    _expansionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _expandAnimation = MediaQuery.of(context).orientation ==
            Orientation.portrait
        ? Tween<double>(begin: 0.19, end: 1.0).animate(
            CurvedAnimation(parent: _expansionController, curve: Curves.ease))
        : Tween<double>(begin: 0.40, end: 1.0).animate(
            CurvedAnimation(parent: _expansionController, curve: Curves.ease));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (!_expansionController.isAnimating) {
      song = Provider.of<AudioPlayerInfo>(context).currentPlayingSong;
      currentIndex = Provider.of<AudioPlayerInfo>(context).currentIndex;
    }
    return AnimatedBuilder(
      animation: _expansionController,
      builder: (context, child) {
        if (Provider.of<AudioPlayerInfo>(context).audioPlayer.state ==
            AudioPlayerState.PLAYING)
          _controller.forward();
        else if (Provider.of<AudioPlayerInfo>(context).audioPlayer.state !=
            AudioPlayerState.PLAYING) _controller.reverse();

        if (Provider.of<AudioPlayerInfo>(context).shouldDisplayProgress ==
                false &&
            _expandAnimation.value >= 0.5)
          Provider.of<AudioPlayerInfo>(context).shouldDisplayProgress = true;

        if (Provider.of<AudioPlayerInfo>(context).shouldDisplayProgress ==
                true &&
            _expandAnimation.value < 0.5)
          Provider.of<AudioPlayerInfo>(context).shouldDisplayProgress = false;
          
        return GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) {
            if (details.delta.dy < -5 && _expandAnimation.isDismissed){
              Provider.of<AudioPlayerInfo>(context).musicScreenPageController = PageController(initialPage: Provider.of<AudioPlayerInfo>(context).currentIndex);
              _expansionController.forward();
            }
              
            if (details.delta.dy > 5 && _expandAnimation.isCompleted){
              _expansionController.reverse();
            }
              
          },
          child: Container(
            color: const Color(0xff232323),
            height: MediaQuery.of(context).size.height * _expandAnimation.value,
            child: _expandAnimation.value < 0.5
                ? child
                : MusicPlayerScreen(
                    _controller, _expansionController),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: TabBar(
              indicatorColor: primaryColor,
              controller: widget._tabController,
              tabs: <Widget>[
                Tab(icon: Icon(Icons.music_note, color: primaryColor)),
                Tab(icon: Icon(Icons.album, color: primaryColor)),
                Tab(icon: Icon(Icons.person_outline, color: primaryColor)),
                Tab(icon: Icon(Icons.playlist_play, color: primaryColor)),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: Text(song != null? song.title : "No Song",
                style: TextStyle(color: marble, fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                if (_expandAnimation.isDismissed) {
                  _expansionController.forward();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    color: primaryColor,
                    onPressed: () =>
                        Provider.of<AudioPlayerInfo>(context).skipPrevious(),
                  ),
                  IconButton(
                    color: primaryColor,
                    iconSize: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 35
                        : 25,
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _controller,
                    ),
                    onPressed: () => setState(() => playPause()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    color: primaryColor,
                    onPressed: () =>
                        Provider.of<AudioPlayerInfo>(context).skipNext(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void playPause() {
    if (_controller.isCompleted) {
      _controller.reverse();
      Provider.of<AudioPlayerInfo>(context).pause();
    } else if (_controller.isDismissed) {
      _controller.forward();
      Provider.of<AudioPlayerInfo>(context).resume();
    }
  }
}
