import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mount_music_player/ui_colors.dart';
import '../Widgets/bottom_play_area.dart';
import './tracks_page.dart';
import './playlists_page.dart';
import './albums_page.dart';
import './artists_page.dart';
import '../state/player_state.dart';

class MusicHomePage extends StatefulWidget {
  @override
  _MusicHomePageState createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  double height;
  var songs, albums, artists, playlists;

  @override
  void initState() {
    height = -1;
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    height = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height * 0.81
        : MediaQuery.of(context).size.height * 0.6;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool dataIsValid = Provider.of<AudioData>(context).dataIsReady;
    if (dataIsValid) {
      getData();
      if (height.isNegative) {
        height = MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.81
            : MediaQuery.of(context).size.height * 0.6;
      }
      return ChangeNotifierProvider(
        builder: (context) => AudioPlayerInfo(
            currentPlayingSong: songs[0], currentPlayingList: songs),
        child: Scaffold(
          backgroundColor: darkTheme,
          appBar: null,
          body: Stack(
            children: <Widget>[
              Container(
                height: height,
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    Tracks(songs),
                    Albums(albums),
                    Artists(artists),
                    Playlists(playlists),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomPlayArea(_tabController),
              ),
            ],
          ),
        ),
      );
    } else
      return Container(
        color: darkTheme,
        child: const Center(
          child: const FlutterLogo(
            size: 50.0,
          ),
        ),
      );
  }

  void getData() {
    songs = Provider.of<AudioData>(context).songs;
    albums = Provider.of<AudioData>(context).albums;
    artists = Provider.of<AudioData>(context).artists;
    playlists = Provider.of<AudioData>(context).playlists;
  }
}
